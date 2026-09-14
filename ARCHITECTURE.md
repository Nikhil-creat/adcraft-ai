# AdCraft AI — Hyper-Engine v2.0
### Enterprise Architecture Reference
**Designed & Developed by Nikhil Chary Sriramoju**
GitHub: https://github.com/Nikhil-creat · LinkedIn: https://in.linkedin.com/in/nikhil-chary-sriramoju-95041b38a · nikhilsriramoju66@gmail.com

This document accompanies `adcraft-ai.html` — a working, click-through prototype of the dashboard (concept generation, A/B variants, aspect-ratio reflow, contrast/a11y scoring, and real PNG export via HTML canvas). It gives the production backend design the prototype is modeled on, for a real Next.js/FastAPI build-out.

---

## 1. Workflow

```
User Input ──▶ Brand DNA Scraper (Puppeteer + ColorThief) ──▶ BrandProfile
                                                                    │
                                                                    ▼
                                              Concept LLM (Claude/GPT-4o) → 3 Variant JSON
                                                                    │
                              ┌─────────────────────────────────────┼─────────────────────────────────────┐
                              ▼                                     ▼                                     ▼
                    Image Gen (FLUX.1 Pro)                Reflow Engine (1:1/9:16/16:9)         Contrast/A11y Scorer
                              │                                     │                                     │
                              └─────────────────────────────────────┼─────────────────────────────────────┘
                                                                    ▼
                                              Render Queue (BullMQ + Redis) → Fargate Worker
                                                          (Fabric.js composite → Remotion/FFmpeg)
                                                                    │
                                                                    ▼
                                                    Asset Store (S3) → PNG / PDF / GIF / MP4
```

## 2. Prisma Schema

```prisma
generator client { provider = "prisma-client-js" }
datasource db { provider = "postgresql"; url = env("DATABASE_URL") }

model User {
  id            String      @id @default(uuid())
  email         String      @unique
  name          String?
  workspaces    WorkspaceMember[]
  createdAt     DateTime    @default(now())
}

model Workspace {
  id            String      @id @default(uuid())
  name          String
  members       WorkspaceMember[]
  brandProfiles BrandProfile[]
  campaigns     Campaign[]
  createdAt     DateTime    @default(now())
}

model WorkspaceMember {
  id            String      @id @default(uuid())
  userId        String
  workspaceId   String
  role          String      @default("editor")
  user          User        @relation(fields: [userId], references: [id])
  workspace     Workspace   @relation(fields: [workspaceId], references: [id])
  @@unique([userId, workspaceId])
}

model BrandProfile {
  id            String      @id @default(uuid())
  workspaceId   String
  name          String
  sourceUrl     String?
  tone          String
  colorPrimary  String
  colorSecondary String
  colorAccent   String
  colorBackground String
  logoUrl       String?
  fontFamily    String?
  workspace     Workspace   @relation(fields: [workspaceId], references: [id])
  campaigns     Campaign[]
}

model Campaign {
  id            String      @id @default(uuid())
  workspaceId   String
  brandProfileId String
  valueProp     String
  status        String      @default("draft")
  workspace     Workspace   @relation(fields: [workspaceId], references: [id])
  brandProfile  BrandProfile @relation(fields: [brandProfileId], references: [id])
  variants      Variant[]
  createdAt     DateTime    @default(now())
}

model Variant {
  id                String    @id @default(uuid())
  campaignId        String
  variantType       String
  headline          String
  subHeadline       String
  ctaText           String
  microCopy         String
  fluxPrompt        String
  motionPrompt      String
  accessibilityScore Int
  campaign          Campaign  @relation(fields: [campaignId], references: [id])
  assets            Asset[]
}

model Asset {
  id            String      @id @default(uuid())
  variantId     String
  ratio         String      // 1x1 | 9x16 | 16x9
  type          String      // png | pdf | gif | mp4
  url           String
  variant       Variant     @relation(fields: [variantId], references: [id])
  renderJob     RenderJob?
}

model RenderJob {
  id            String      @id @default(uuid())
  assetId       String      @unique
  status        String      @default("queued") // queued | processing | complete | failed
  progress      Int         @default(0)
  asset         Asset       @relation(fields: [assetId], references: [id])
  startedAt     DateTime?
  completedAt   DateTime?
}
```

## 3. Backend API Routes (TypeScript / Express, sketched)

```ts
// POST /api/v1/brand/scrape
router.post('/brand/scrape', async (req, res) => {
  const { url } = req.body;
  const dom = await fetchAndParse(url);           // Puppeteer render
  const palette = await extractPalette(dom.screenshot); // ColorThief / node-vibrant
  const logo = await extractLogoWithBgRemoval(dom);      // remove.bg-style pipeline
  const fonts = detectFontFamilies(dom.computedStyles);
  res.json({ palette, logo, fonts });
});

// POST /api/v1/campaign/generate-concept
router.post('/campaign/generate-concept', async (req, res) => {
  const { brandProfile, valueProp, tone } = req.body;
  const schema = await llm.complete({
    model: 'claude-sonnet-4-6',
    system: CREATIVE_EXECUTION_SYSTEM_PROMPT,
    prompt: buildConceptPrompt(brandProfile, valueProp, tone),
    responseFormat: 'json',
  });
  const campaign = await prisma.campaign.create({ data: toCampaignRecord(schema) });
  res.json(campaign);
});

// POST /api/v1/render/poster
router.post('/render/poster', async (req, res) => {
  const { variantId, ratios } = req.body; // e.g. ['1x1','9x16','16x9']
  const jobs = await Promise.all(ratios.map(r => queue.add('render-poster', { variantId, ratio: r })));
  res.json({ jobs: jobs.map(j => j.id) });
});

// POST /api/v1/render/gif-video
router.post('/render/gif-video', async (req, res) => {
  const { variantId, format } = req.body; // 'gif' | 'mp4'
  const job = await queue.add('render-motion', { variantId, format, engine: 'remotion' });
  res.json({ jobId: job.id });
});
```

## 4. Render Worker (Python FastAPI + BullMQ consumer)

```python
@worker.task("render-poster")
async def render_poster(variant_id: str, ratio: str):
    variant = await db.variant.find_unique(where={"id": variant_id})
    canvas = FabricCanvas(dims=RATIO_DIMS[ratio])
    canvas.add_background_shader(variant.campaign.brand_profile.color_palette)
    canvas.add_text(variant.headline, role="headline")
    canvas.add_text(variant.sub_headline, role="subheadline")
    canvas.add_cta(variant.cta_text)
    score = compute_contrast_score(canvas)
    png_url = await s3_upload(canvas.export_png())
    await db.asset.create(data={"variant_id": variant_id, "ratio": ratio, "type": "png", "url": png_url})
    return {"score": score, "url": png_url}
```

## 5. Frontend Dashboard (Next.js) — component map

- `<BrandInputPanel />` — name, value prop, URL scraper trigger, tone selector
- `<PaletteExtractor />` — shows scraped hex swatches + font preview
- `<CanvasWorkspace />` — Fabric.js + WebGL shader layer, aspect-ratio tabs
- `<VariantSwitcher />` — A/B/C angle preview cards
- `<AccessibilityBadge />` — live contrast score
- `<ExportBar />` — PNG / PDF / GIF / MP4 triggers → polls `RenderJob.status`

## 6. Agentic Orchestration Layer

The browser prototype's "Agent Console" (Scraper → Strategist → Copywriter → Designer → QA) mirrors a real agentic pipeline. In production this is an actual multi-agent chain, not a fixed script — each agent is a tool-using LLM call that can branch, retry, or re-plan:

```
┌─────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌─────────────┐
│ Scraper     │──▶│ Strategist   │──▶│ Copywriter   │──▶│ Designer     │──▶│ QA Agent    │
│ Agent       │   │ Agent        │   │ Agent        │   │ Agent        │   │             │
│             │   │              │   │              │   │              │   │             │
│ tools:      │   │ tools:       │   │ tools:       │   │ tools:       │   │ tools:      │
│ • fetch_url │   │ • market_ctx │   │ • llm.write  │   │ • flux.gen   │   │ • contrast  │
│ • ocr_logo  │   │ • pick_angles│   │ • tone_check │   │ • layout_fit │   │ • brand_fit │
│ • palette   │   │              │   │              │   │ • remotion   │   │ • re-queue  │
└─────────────┘   └──────────────┘   └──────────────┘   └──────────────┘   └─────────────┘
```

- Each agent runs as a step in a durable workflow (e.g. Temporal, or a BullMQ job chain) so a failed step retries without re-running the whole pipeline.
- The **QA Agent** can loop back to the Designer or Copywriter agent if a generated variant scores below an accessibility/brand-fit threshold — this is the "agentic" part: it decides whether to accept, retry, or escalate, rather than following a fixed script.
- Agent reasoning/tool-call traces are logged per `RenderJob` for auditability.

## 7. Docker Deployment

This package includes a ready-to-use container setup for the full stack:

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the Node.js/Express API Gateway |
| `Dockerfile.worker` | Builds the Python/FastAPI render worker (ffmpeg, Remotion/canvas deps) |
| `docker-compose.yml` | Orchestrates frontend, API, worker, Postgres, and Redis together |

```bash
# from the project root, with a real Next.js frontend/ and worker/ folder in place
export ANTHROPIC_API_KEY=sk-...
export REPLICATE_API_TOKEN=r8_...
docker compose up --build
```

This brings up:
- `frontend` — Next.js dashboard on `:3000`
- `api` — Express API Gateway on `:4000`
- `worker` — FastAPI render worker on `:8000`
- `postgres` — Postgres 16 on `:5432`
- `redis` — Redis 7 on `:6379`

The compose file assumes a `frontend/` folder (Next.js app) and a `worker/` folder (the Python service) alongside this repo's backend code — scaffold those from the component/route sketches above, then `docker compose up --build` brings the whole platform up with one command.

---

*The interactive prototype (`adcraft-ai.html`) implements the concept-generation logic, aspect-ratio reflow, A/B variant switching, canvas-based procedural shader rendering, real contrast/accessibility scoring, animated GIF export, batch ZIP export, local campaign history, and a simulated agent console entirely client-side, so it runs standalone with no backend required. The Docker/Prisma/API layer above is the real backend to build when you're ready to wire in live AI image generation and brand scraping.*
