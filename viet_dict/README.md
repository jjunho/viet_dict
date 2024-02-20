# viet_dict
>
> Built with [Elm Land](https://elm.land) 🌈

## Vietnamese Dictionary

This is a Vietnamese Chu Nom dictionary app built with Elm. It is a work in progress.
It is a simple search over the list of words found at [ChuNom.org](https://chunom.org/pages/standard-list/?max=2000&download=1).

## Features

- [X] Search for words in Vietnamese Quoc Ngu and get the corresponding Chu Nom.
- [ ] Search for words in Chu Nom and get the corresponding Vietnamese Quoc Ngu.

## Local development

```bash
# Requires Node.js v18+ (https://nodejs.org)
npx elm-land server
```

## Deploying to production

Run `bash dist.sh` to build the app. The output will be in the `dist` folder.
