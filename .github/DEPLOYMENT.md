# GitHub Actions Deployment Setup

## Required Secrets

Add these secrets to your GitHub repository settings:
**Settings → Secrets and variables → Actions → New repository secret**

### HuggingFace Spaces

1. **HF_TOKEN**
   - Get from: https://huggingface.co/settings/tokens
   - Create new token with "write" access
   - Add to GitHub secrets

### Vercel

1. **VERCEL_TOKEN**
   - Get from: https://vercel.com/account/tokens
   - Create new token

2. **VERCEL_ORG_ID**
   - Run: `vercel link` in your project
   - Find in `.vercel/project.json`

3. **VERCEL_PROJECT_ID**
   - Run: `vercel link` in your project
   - Find in `.vercel/project.json`

### Cloudflare Pages

1. **CLOUDFLARE_API_TOKEN**
   - Get from: https://dash.cloudflare.com/profile/api-tokens
   - Create token with "Cloudflare Pages" permissions

2. **CLOUDFLARE_ACCOUNT_ID**
   - Find in Cloudflare dashboard URL
   - Format: `https://dash.cloudflare.com/{ACCOUNT_ID}/`

## Deployment Workflow

Once secrets are configured, deployments happen automatically:

1. **Push to main branch** → Triggers all deployments
2. **Manual trigger** → Go to Actions tab, select workflow, click "Run workflow"

## URLs After Deployment

- **HuggingFace**: https://huggingface.co/spaces/meta-introspector/zkprologml-dashboard
- **Vercel**: https://zkprologml-dashboard.vercel.app
- **Cloudflare**: https://zkprologml-dashboard.pages.dev

## Testing Locally

```bash
cd data/proofs/deploy
python3 -m http.server 8000
```

Open: http://localhost:8000
