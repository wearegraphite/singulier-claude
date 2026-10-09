# Premiers pas

[English version](getting-started.en.md)

Ce guide est pour vous si vous n'êtes pas développeur. Une fois terminé, vous
pourrez poser des questions à Claude sur nos projets (« comment est calculé ce
prix ? ») et créer ou suivre des issues GitHub, sans passer par un développeur.

Vous n'avez **rien à taper** : vous collez un message, Claude fait le reste et
vous dit quand cliquer. Comptez 15 à 30 minutes, une seule fois.

---

## Avant de commencer

- [ ] L'**application Claude** est installée sur votre ordinateur (https://claude.ai/download) et vous êtes connecté avec votre compte Singulier.
- [ ] Vous avez un **compte GitHub**. Sinon, créez-le gratuitement sur https://github.com/signup avec votre adresse professionnelle.
- [ ] Vous avez envoyé votre **nom d'utilisateur GitHub** à l'administrateur du projet, et il vous a confirmé votre accès.

---

## Étape 1 : ouvrir Claude Code

1. Ouvrez l'application Claude.
2. En haut de la fenêtre, cliquez sur l'icône **`</>`** (à droite de la bulle de discussion) :

   ![Bouton Code dans l'application Claude](images/code-tab-toggle.png)

   Vous êtes dans **Claude Code** : c'est le mode où Claude peut travailler sur votre ordinateur. La bulle à gauche est le chat habituel, il ne peut pas faire la configuration.
3. Démarrez une nouvelle session. Si Claude vous demande de choisir un dossier, prenez votre dossier **Documents**.

---

## Étape 2 : coller le message de configuration

Copiez tout le bloc ci-dessous (bouton de copie en haut à droite du bloc sur
GitHub), collez-le dans Claude Code et envoyez.

```text
Parle-moi en français, simplement : je ne suis pas technique. Configure mon ordinateur pour travailler sur les projets Singulier. Lance toi-même toutes les commandes. Ne me demande d'agir que quand c'est indispensable (cliquer dans un installateur, valider dans le navigateur), une chose à la fois, en me disant exactement où cliquer.

Étapes, dans l'ordre. Annonce chaque étape en une phrase, puis fais-la.
1. Système : détecte macOS ou Windows.
2. git : vérifie `git --version`. S'il manque : sur macOS lance `xcode-select --install` et dis-moi de cliquer sur « Installer » dans la fenêtre qui s'ouvre, puis attends que j'aie fini ; sur Windows lance `winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements`.
3. GitHub CLI : vérifie `gh --version`. S'il manque : sur macOS télécharge le fichier `gh_*_macOS_universal.pkg` de la dernière version (https://api.github.com/repos/cli/cli/releases/latest), ouvre-le avec `open` et guide-moi dans l'installateur (il demandera le mot de passe de l'ordinateur) ; sur Windows lance `winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements`.
   Sur Windows, si tu as installé git ou gh : dis-moi de quitter complètement l'application Claude, de la rouvrir et de recoller ce message. Arrête-toi là.
4. Connexion GitHub : si `gh auth status` échoue ou n'affiche pas le droit `project`, lance en arrière-plan `gh auth login --web -h github.com -p https -s project`, lis sa sortie, donne-moi le code à 8 caractères et le lien https://github.com/login/device, et attends que je te dise que c'est validé. Vérifie avec `gh auth status`, puis lance `gh auth setup-git`.
5. Accès : lance `gh repo list wearegraphite --limit 100`. Si la liste est vide, donne-moi mon nom d'utilisateur GitHub (`gh api user --jq .login`), dis-moi de l'envoyer à l'administrateur du projet, et arrête-toi.
6. Plugin Singulier : si tu n'as pas déjà de skills `singulier:`, ajoute dans mes réglages Claude utilisateur (`settings.json` du dossier de configuration Claude, en général `~/.claude/` ; fusionne, n'écrase rien) : dans `extraKnownMarketplaces`, la clé `singulier` avec `{"source": {"source": "github", "repo": "wearegraphite/singulier-claude"}}` ; dans `enabledPlugins`, `"singulier@singulier": true`.
7. Projets : crée le dossier `Singulier` dans mon dossier personnel. Montre-moi la liste des projets de l'étape 5 avec des noms simples, demande-moi lesquels je veux, et clone chacun avec `gh repo clone wearegraphite/<projet> "<dossier Singulier>/<projet>"`.
8. Fin : résume en trois lignes ce qui est prêt, puis dis-moi de quitter complètement l'application Claude et de la rouvrir.

Si une étape échoue deux fois, arrête-toi et dis-moi quoi envoyer à l'administrateur du projet.
```

Pendant la configuration :

- Claude vous demande parfois l'**autorisation de lancer une commande** : cliquez sur **Autoriser** (ou « Allow »). C'est normal, c'est comme ça qu'il installe les outils.
- Quand il vous donne un **code GitHub**, ouvrez le lien qu'il indique, connectez-vous à GitHub, tapez le code, cliquez sur **Authorize**, puis répondez-lui « c'est fait ».
- À la fin, **quittez complètement l'application Claude et rouvrez-la** (sur Mac : `Cmd + Q`).

---

## Au quotidien

1. Ouvrez l'application Claude et cliquez sur **`</>`**.
2. Démarrez une session et choisissez le dossier du projet : votre dossier personnel, puis **Singulier**, puis le nom du projet.
3. Posez votre question, en français, comme à un collègue.

Le projet se met à jour tout seul à chaque nouvelle session : vous voyez toujours
la version actuelle.

Exemples de demandes :

- « Comment est calculé le prix d'un produit ? »
- « D'où viennent les données du tableau de bord ? »
- « Crée une issue : le bouton d'export ne fait rien sur la page clients. »
- « Où en est-on sur l'intégration du paiement ? »
- « Montre-moi mes issues ouvertes. »
- « Récupère aussi le projet X sur mon ordinateur. »
- « Vérifie mon installation. »

Ce qu'il faut savoir :

- Claude **ne peut pas modifier le code** du projet. Si vous avez besoin d'un changement, il vous propose de rédiger une issue pour les développeurs.
- Il vous **montre toujours une issue avant de la créer** ou de la modifier.
- Il fait la différence entre ce qu'il a vérifié dans le code et ce qu'il suppose. En cas de doute, il vous dit qui contacter.

---

## Problèmes fréquents

| Ce que vous voyez | Que faire |
| --- | --- |
| Vous ne voyez pas l'icône `</>` | Mettez à jour l'application Claude (menu de l'application) ou réinstallez-la depuis https://claude.ai/download. |
| Claude dit qu'il ne peut pas lancer de commandes | Vous êtes dans le chat (bulle) : cliquez sur `</>`. |
| Claude dit que le projet n'a pas pu être mis à jour | Vérifiez votre connexion internet. Si ça persiste, demandez-lui « vérifie mon installation ». |
| Claude dit que vous n'avez pas accès à un projet | Envoyez votre nom d'utilisateur GitHub à l'administrateur du projet. |
| Autre chose | Envoyez une capture d'écran à l'administrateur du projet. |
