# Master Feature Plan & Architecture Roadmap

This document outlines the architectural blueprints and implementation phases for the next core modules:
1. **`media`**: Pre-signed GCS uploads, ephemeral auto-TTL staging, and variant processing.
2. **`email`**: Frictionless email verification and match alert delivery.
3. **`matching`**: AI visual similarity search with PostgreSQL `pgvector` and spatial indexing.

---

## 1. `modules/media`: Image Upload & Storage Architecture

### Overview
A standalone domain library responsible for validating upload metadata, issuing Google Cloud Storage (GCS) pre-signed PUT URLs, promoting verified files, and generating responsive variants.

### Directory Structure
```directory
modules/media/
├── Gemfile
├── Rakefile
├── media.gemspec
├── lib/
│   ├── media.rb                  # Public Facade
│   └── media/
│       ├── errors.rb             # Domain exceptions (InvalidContentType, FileTooLarge)
│       ├── upload_ticket.rb      # DTO (photo_id, upload_url, method, headers, expires_in)
│       ├── file_validator.rb     # Validates MIME types (JPEG, PNG, WebP) and size (<= 5MB)
│       ├── storage.rb            # Storage factory & adapters (InMemoryStorage, GcsStorage)
│       └── image_processor.rb    # ruby-vips WebP variant generator (v2)
└── test/
    ├── test_helper.rb
    └── media/
        ├── media_test.rb         # Facade unit tests (< 3ms)
        ├── file_validator_test.rb
        └── storage_test.rb       # Shared Contract Tests
```

### Phased Evolution Roadmap:

- [ ] **v1 (MVP - Direct Ingest & Staging)**:
  - **Two-Bucket / Folder Staging**:
    - **Temp Bucket**: Configured with a 24-hour GCS Lifecycle Auto-Delete rule.
    - **Permanent Bucket**: Public CDN-backed storage for confirmed report photos.
  - **Facade Operations**:
    - `create_upload_ticket(filename:, content_type:, byte_size:)`: Validates metadata and returns pre-signed V4 PUT ticket pointing to Temp Bucket.
    - `promote_photo(photo_id)`: Executes instant cloud-native server-side copy (`temp_file.copy(permanent_bucket, ...)`).
    - `public_url(photo_id)`: Resolves public CDN/GCS read URL.
  - **Dual Adapters**: `InMemoryStorage` (fast in-memory unit tests) and `GcsStorage` (`google-cloud-storage` gem).
- [ ] **v2 (Responsive Variant Pipeline)**:
  - Uses `ruby-vips` to generate `thumbnail (120x120)`, `card (400x400)`, and `full (1200)` WebP images upon report promotion.
- [ ] **v3 (Self-Healing Reconciliation)**:
  - Rake task / Cron job (`bin/rails media:reconcile_variants`) running in batches (e.g. 50 photos/min) using `last_processed_at` watermarking to backfill missing sizes or handle format migrations.
- [ ] **v4 (Client-Side Pre-Compression & Smart Crop)**:
  - Browser canvas / Web Worker pre-compression in Vue (10MB ➔ 300KB before upload).
  - Attention-based smart cropping with `libvips` so pet faces are never cut off in thumbnails.

---

## 2. `modules/email`: Email Verification & Notifications

### Overview
A standalone notification library enabling fast, frictionless report submission while guaranteeing verified contact channels for AI match alerts.

### The Frictionless Verification & Publishing Flow:
1. **Quick Submit**: User inputs Photo + Pet Details + Location + Email Address.
2. **Draft Created**: Saved in `pending_confirmation` state.
3. **Verification Email Sent**: Emits `ReportPublicationRequested(email, token, report_id)`.
4. **User Clicks Link in Inbox**:
   - Single-use token is validated.
   - Email is marked **VERIFIED**.
   - Report transitions to **PUBLISHED** (appears on map & search index).
   - Emits `AnnouncementPublished`.

### Directory Structure
```directory
modules/email/
├── lib/
│   ├── email.rb                  # Public Facade
│   └── email/
│       ├── template_renderer.rb  # HTML/Text email templates
│       ├── adapters.rb           # Delivery adapters (InMemoryAdapter, SmtpAdapter)
│       └── subscribers.rb        # EventsBus listeners
└── test/
    └── email/
        └── email_test.rb         # Fast in-memory unit tests (< 2ms)
```

---

## 3. `modules/matching`: AI Visual Similarity & Spatial Matchmaker

### Overview
An autonomous matchmaking engine that scans newly published "FOUND" reports against active "LOST" reports using spatial radius constraints and image vector embeddings.

### Architecture & PostgreSQL `pgvector`:
1. When a photo is uploaded, **Google Cloud Vertex AI Multimodal Embeddings** (or local OpenCLIP) generates a 512-dimension vector representing the pet's visual appearance.
2. When a "FOUND" report is published, a single PostgreSQL query combines **Geographic Distance (GiST)** and **Visual Cosine Similarity (Vector index)**:

```sql
SELECT 
  id, 
  title,
  (location <@> point(:found_lon, :found_lat)) AS distance_km,
  (photo_embedding <=> :found_photo_embedding) AS visual_distance
FROM public_announcements
WHERE 
  status = 'lost'
  AND (location <@> point(:found_lon, :found_lat)) <= 50 -- within 50 km
ORDER BY visual_distance ASC
LIMIT 5;
```

3. **Event Notification**:
   - If `visual_distance < threshold` (similarity > 85%), emits `PotentialPetMatchFound(lost_id, found_id, score)`.
   - `modules/email` automatically sends an urgent match notification to the verified owner.

---

## Complete Modular Monolith System Map

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     auth        │       │  announcements  │       │     media       │
│ User & Session  │       │ Report & Drafts │       │ GCS Upload &    │
│ Management      │       │ Lifecycle       │       │ Variant Storage │
└────────┬────────┘       └────────┬────────┘       └────────┬────────┘
         │                         │                         │
         └─────────────────────────┼─────────────────────────┘
                                   │ EventsBus
         ┌─────────────────────────┼─────────────────────────┐
         │                         │                         │
┌────────▼────────┐       ┌────────▼────────┐       ┌────────▼────────┐
│announcements_map│       │  announcements_ │       │     email       │
│ Map Pin Greedy  │       │     search      │       │ Confirmation &  │
│ Clustering Grid │       │ Spatial Index   │       │ Alert Delivery  │
└─────────────────┘       └─────────────────┘       └────────┬────────┘
                                                             │
                                                    ┌────────▼────────┐
                                                    │    matching     │
                                                    │ Spatial + AI    │
                                                    │ Vector Matcher  │
                                                    └─────────────────┘
```
