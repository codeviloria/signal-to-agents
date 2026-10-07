# Publicar el blog gratis en Cloudflare Pages

**Atajo:** `bash scripts/publish.sh` hace el build, crea o actualiza el repo en GitHub y despliega en Cloudflare Pages (`https://signal-to-agents.pages.dev`). La primera vez abre el navegador para iniciar sesión en Cloudflare. Para cada post nuevo, vuelve a correrlo.

Lo de abajo explica el proceso manual.

**Por qué Cloudflare y no AWS:** el plan gratuito de Cloudflare Pages no vence y alcanza para un blog estático: HTTPS, CDN global, un subdominio `*.pages.dev` y un deploy automático cada vez que haces `git push`. En AWS, la capa gratuita de Amplify/CloudFront tiene límites por tiempo y por uso, y requiere más configuración (S3, CloudFront, certificados). AWS conviene más adelante, si quieres mostrar infraestructura en el portafolio.

## 1. Personalizar (5 min)
- `src/consts.ts` → `LINKEDIN_URL`, `GITHUB_URL` (y `AUTHOR` si quieres tu nombre completo).
- `astro.config.mjs` → `site:` con tu URL final (necesaria para el sitemap, el RSS y el preview en LinkedIn).
- `src/content/blog/5g-nsa-agent-tool-calling-gemma4.md` → busca los `TODO(Gino)`:
  - pega la respuesta final que te dé `gemma4:e2b` y la captura del trace de LangSmith,
  - pon el link al repo `5g-nsa-agent`.

## 2. Probar en local
```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # genera dist/
```

## 3. Subir a GitHub
Crea dos repos públicos: `signal-to-agents` (este blog) y `5g-nsa-agent` (el código del post).
```bash
cd ai-blog
git init && git add . && git commit -m "Blog inicial"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/signal-to-agents.git
git push -u origin main
```

## 4. Conectar Cloudflare Pages
1. dash.cloudflare.com → crea una cuenta gratis.
2. **Workers & Pages → Create → Pages → Connect to Git** → elige el repo.
3. Configuración del build:
   - Framework preset: **Astro**
   - Build command: `npm run build`
   - Build output directory: `dist`
   - Variable de entorno: `NODE_VERSION = 22`, porque Astro exige Node ≥ 22.12.
4. Save and Deploy. Queda en `https://<nombre-del-proyecto>.pages.dev`.

Desde ahí, cada `git push` publica la nueva versión.

## 5. Nuevo post
Crea `src/content/blog/<slug>.md` con este frontmatter:
```yaml
---
title: 'Título'
description: 'Una frase: aparece en Google y en el preview de LinkedIn'
pubDate: '2026-10-10T12:00:00-05:00'
heroImage: '../../assets/<imagen>.png'   # 1200x630 para LinkedIn
---
```

## 6. Dominio propio (opcional)
Si compras un dominio (unos USD 10 al año), agrégalo en Pages → Custom domains y actualiza `site:` en `astro.config.mjs`.
