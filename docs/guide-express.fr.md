# Parler au produit en langage simple

[English version](quick-guide.en.md)

Posez des questions sur un produit, créez des tickets, suivez l'avancement,
en écrivant comme à un collègue. Pas besoin de connaître GitHub.

---

## La première fois (une seule fois, 15 à 30 minutes)

1. Ouvrez l'**application Claude**.
2. Cliquez sur l'icône **`</>`** en haut de la fenêtre (Claude Code).

   ![Bouton Code dans l'application Claude](images/code-tab-toggle.png)

3. Cliquez sur **nouveau chat**, puis choisissez votre dossier **Documents**.
4. Copiez le **message de configuration** ([cliquez ici pour l'afficher](getting-started.fr.md#étape-2--coller-le-message-de-configuration)), collez-le dans le chat et envoyez.
5. Laissez Claude travailler. Quand il vous le demande :
   - cliquez sur **Autoriser** ;
   - tapez le code qu'il vous donne sur la page GitHub qui s'ouvre, puis répondez « c'est fait ».
6. À la fin, **quittez complètement l'application Claude et rouvrez-la**.

---

## À chaque fois

1. Ouvrez l'**application Claude**.
2. Cliquez sur **`</>`**.
3. Cliquez sur **nouveau chat**.
4. Choisissez le dossier **Singulier**, puis le **produit** qui vous intéresse.
5. Écrivez votre demande, simplement :
   - **une question** : « Comment est calculé le prix d'un produit ? »
   - **un ticket** : « Crée un ticket : le bouton d'export ne fait rien sur la page clients. »
   - **un gros sujet** : « Crée un épic pour la refonte de l'export. » Claude le découpe en plusieurs tickets regroupés dans un épic, avec un schéma de l'ordre dans lequel ils seront faits.
   - **l'avancement** : « Où en est-on sur l'intégration du paiement ? »
   - **ce que vous devez vérifier** : « Qu'est-ce que je dois tester ? », puis « J'ai testé #380, c'est bon. » Claude ferme le ticket après votre accord.
6. Claude vous montre le ticket **avant** de le créer : relisez-le, puis répondez « OK » ou dites ce qu'il faut changer.
7. Vous avez donné une capture ou un fichier ? Claude vous demande lesquels mettre dans le ticket. Les images, c'est vous qui les ajoutez sur la page GitHub du ticket : Claude vous donne le lien, glissez-les dans la zone de commentaire en bas.
8. Ticket créé : tapez `/clear` ou ouvrez un **nouveau chat** pour le sujet suivant. Une conversation trop longue rend Claude plus lent et moins précis. Rien n'est perdu : tout est dans le ticket.

---

**Perdu ?** Tapez `/singulier:aide` dans le chat.

**Bloqué ?** Envoyez une capture d'écran à l'administrateur du projet.
