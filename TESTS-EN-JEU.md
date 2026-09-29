# Tests en jeu : WeakAuras Forever

Rien de ce qui a été codé n'a été testé en jeu. Ce fichier donne l'ordre des tests, ce qu'il faut voir, et le prompt
à donner à Claude à la fin.

Pour chaque test, note **OK**, **KO** (avec le texte exact de l'erreur ou ce que tu vois) ou **non testé**.
Les tests marqués 🔴 sont bloquants : s'ils échouent, note-le et passe quand même aux suivants.

---

## Étape 0 : préparation (5 min)

- [ ] Installer **BugGrabber + BugSack** : ils gardent le texte complet des erreurs, mieux que la fenêtre de base.
- [ ] Désactiver ForeverAuras (les deux addons ne doivent pas tourner ensemble).
- [ ] En jeu : `/console scriptErrors 1`, puis `/reload`.
- [ ] `/wa` ouvre les options, sans erreur.
- [ ] `/wa tutorial` ouvre le tutoriel, et les deux boutons d'import marchent.

Pour copier une erreur : ouvre BugSack, copie la première ligne et les 5 lignes de pile qui suivent.

---

## Étape 1 : vérifications du client (2 min, à coller telles quelles)

Tape chaque commande et note le résultat affiché.

| # | Commande | Résultat attendu |
|---|---|---|
| 1.1 | `/dump select(4, GetBuildInfo())` | un nombre inférieur à 20000 (16001) |
| 1.2 | `/dump WOW_PROJECT_ID, WOW_PROJECT_MAINLINE` | noter les deux valeurs |
| 1.3 | `/dump C_SpecializationInfo and C_SpecializationInfo.GetSpecialization()` | un numéro de spé, ou nil |
| 1.4 | `/dump C_Secrets ~= nil, issecretvalue ~= nil` | `true, true` |
| 1.5 | `/dump C_CooldownViewer ~= nil` | `true` |
| 1.6 | `/dump GetInventoryItemDurability(1)` | deux nombres (si casque équipé) |
| 1.7 | `/dump C_Minimap.GetNumTrackingTypes()` | un nombre ≥ 1 |
| 1.8 | `/dump GetInstanceInfo()` dans un donjon | noter le 3ᵉ nombre (ID de difficulté) |
| 1.9 | `/dump C_EncounterTimeline and C_EncounterTimeline.IsFeatureAvailable()` | noter (décide la phase E) |
| 1.10 | `/dump C_EncounterTimeline and C_EncounterTimeline.IsFeatureEnabled()` | noter |
| 1.11 | `/dump C_Texture.GetAtlasInfo("RaidFrame-Icon-DebuffMagic") ~= nil` | `true` |

---

## Étape 2 : 🔴 le combat de base (15 min, sur n'importe quel mob)

### 2.1 Icône de cooldown en combat
- [ ] Crée une aura Icon, trigger **Cooldown** sur un de tes sorts (ID exact).
- [ ] Hors combat : lance le sort, le cadran tourne et le chiffre descend.
- [ ] En combat : pareil, sans erreur. **Risque n°1** : si une erreur parle de `SetCooldown` ou de fonction protégée, note-la en entier.

### 2.2 Buff posé en combat
- [ ] Aura Icon, trigger **Aura**, sur toi, un buff que tu te poses (spell ID exact).
- [ ] Ajoute un texte `%p` et un texte `%s`.
- [ ] Hors combat : icône, durée qui descend, stacks.
- [ ] Pose le buff **en combat** : l'icône apparaît, `%p` descend, `%s` montre les stacks.
- [ ] À la fin du combat, l'aura reste juste (pas de doublon, pas de figé).

### 2.3 Barre de vie et de mana en combat
- [ ] Aura Progress Bar, trigger **Health** sur `target`, puis une autre **Power** sur `player`.
- [ ] En combat, les deux barres bougent.
- [ ] Ajoute une condition « Health < 50 % » : elle garde son dernier état en combat (attendu), et se remet à jour à la fin.

### 2.4 Global Cooldown
- [ ] Trigger **Global Cooldown** : il s'affiche à chaque sort, en combat aussi.
- [ ] `/wa pstart`, 20 s de combat, `/wa pstop`, `/wa pprint` : note les 3 lignes les plus chères.

---

## Étape 3 : armes, munitions, enchantements (10 min)

- [ ] **Swing Timer, main hand** : la barre repart à chaque coup.
- [ ] **Off hand** (si deux armes) : barre séparée, juste après un buff de vitesse d'attaque.
- [ ] **Ranged / baguette** : la barre suit le tir automatique.
- [ ] **Swing Timer, Target In Range** : réglé sur In Range, l'aura s'affiche au corps à corps ; sur Out of Range, loin de la cible ; sans cible, ni l'un ni l'autre.
- [ ] **Ammo** (chasseur, guerrier, voleur) : Count = munitions équipées, Total Carried = toutes les munitions des sacs ; le filtre d'objet Ammo Item ne montre l'aura qu'avec la munition choisie.
- [ ] **Enchantement temporaire** (poison, pierre à aiguiser, huile) : sur les deux armes, les deux s'affichent avec leur durée.

---

## Étape 4 : dissipation (10 min, un mob ou un joueur qui pose des débuffs)

- [ ] Bordure avec **Color by Dispel Type** sur une aura de débuff : magie bleue, malédiction violette, poison verte, maladie marron.
- [ ] Même test **en combat** : les couleurs restent justes. Si une couleur est fausse, note le type et la couleur vue (les ID de type sont supposés).
- [ ] Sous-élément **Dispel Type Icon** : hors combat, l'icône Blizzard du type ; en combat, un rond de la couleur du type.
- [ ] Une condition qui change la couleur de la bordure gagne toujours sur la couleur de dissipation.

---

## Étape 5 : nouveaux triggers et options (15 min)

- [ ] **Bag Space** : ramasse un objet, Free Slots baisse ; Include Specialty Bags compte le carquois.
- [ ] **Equipment Durability** : meurs une fois, Lowest et Overall baissent ; un seul slot fonctionne.
- [ ] **Role** : en groupe, choisis un rôle dans la recherche de groupe, l'aura suit.
- [ ] **Tracking** : Find Herbs par son ID de sort, l'aura suit l'activation ; Inverse fait l'inverse.
- [ ] **Load, Instance Type** : dans un donjon, la liste des difficultés est remplie et le filtre marche.
- [ ] **Conditions, Secret Restrictions Active** : vrai en combat, faux après.
- [ ] **Cooldown, condition On Global Cooldown** (avec Show Global Cooldown) + Hide Cooldown Text : le chiffre disparaît pendant le GCD seulement.
- [ ] **Aura, Elapsed Time ≥ 5** : l'aura s'affiche 5 s après la pose du buff.
- [ ] **Texte `%p`** : format Old / Modern et Increase Precision Below suivent les réglages, en combat aussi.

---

## Étape 6 : Cooldown Manager (5 min)

- [ ] `/wa cdm` hors combat : le Cooldown Manager de Blizzard s'affiche / se cache. En combat : message de refus.
- [ ] Après `/wa cdm`, aucune erreur « action bloquée » (taint) en combat.
- [ ] Trigger Cooldown : la liste **From the Cooldown Manager** est remplie et règle le sort.
- [ ] Trigger Aura (Exact Spell ID coché) : la liste **From the Cooldown Manager** ajoute les ID d'un buff suivi.

### 6.5 Lien Cooldown Manager ↔ aura en combat (décide si on reconnaît un buff secret par son sort)

But : savoir si un addon peut lire, en combat, quel buff le Cooldown Manager affiche. Si oui, on pourra reconnaître
par son ID de sort un buff posé en combat dont les données sont secrètes (comme le fait ForeverAuras).

1. [ ] Hors combat : `/wa cdm` pour afficher le Cooldown Manager. Dans ses réglages (Edit Mode > Cooldown Manager),
   mets 2 ou 3 de tes buffs dans **Tracked Buffs**, dont un qui apparaît en combat (proc, bijou, talent).
2. [ ] Hors combat, buff actif, colle cette commande (une seule ligne) :
   ```
   /run for _,v in ipairs({BuffIconCooldownViewer,BuffBarCooldownViewer}) do for _,f in ipairs(v and v:GetItemFrames() or {}) do local i=f:GetAuraSpellInstanceID() local s=f.auraSpellID print(f:GetCooldownID(), type(i), issecretvalue(i) and "SECRET" or i, issecretvalue(s) and "SECRET" or s) end end
   ```
   Note ce qui s'affiche : une ligne par buff suivi (ID d'entrée, type, ID d'instance, ID de sort).
3. [ ] **En combat**, avec le buff posé pendant le combat, recolle la même commande. Note les lignes.
4. [ ] Toujours en combat, colle :
   ```
   /run local t=C_UnitAuras.GetUnitAuraInstanceIDs("player","HELPFUL") print(#t) for _,i in ipairs(t) do print(i, C_Secrets and C_Secrets.ShouldUnitAuraInstanceBeSecret and C_Secrets.ShouldUnitAuraInstanceBeSecret("player", i)) end
   ```
   Note si l'ID d'instance vu à l'étape 3 apparaît ici, et si sa ligne dit `true` (aura secrète).

Résultat utile : à l'étape 3, l'ID d'entrée est un nombre et l'ID d'instance est un nombre (pas `SECRET`), présent à
l'étape 4. Si la commande 2 ou 3 affiche une erreur, copie-la en entier.

---

## Étape 7 : 🔴 filtres natifs et auras secrètes (10 min)

- [ ] Trigger Aura sur `target`, Debuff, **Native Filter** seul, Is = Crowd Control.
- [ ] Hors combat : un contrôle posé s'affiche, avec son nom.
- [ ] En combat : un contrôle posé s'affiche sans nom, avec icône, durée et stacks dessinés par le jeu.
- [ ] Même aura avec **Clones** et deux contrôles : pas d'erreur, deux icônes.
- [ ] Is = Cast by Me or my Pet : seulement tes débuffs.
- [ ] Une aura sans filtre natif se comporte exactement comme avant.

---

## Étape 8 : groupe, glow, divers (10 min)

- [ ] Action **Glow** (Pixel, Autocast, Proc) sur une icône : le glow est visible et bien dessiné.
- [ ] Trigger Aura en mode groupe (party) : les membres sont trouvés, pas d'erreur de GUID en combat.
- [ ] L'unité Multi-target n'est plus proposée dans le trigger Aura.
- [ ] Un trigger Combat Log affiche l'avertissement « combat log fermé ».
- [ ] Portée : une aura avec condition de portée sur la cible change bien en s'éloignant.

---

## Étape 9 : import ForeverAuras (10 min)

- [ ] Dans ForeverAuras (réactivé seul), exporte 3 ou 4 auras variées : Cooldown Manager, Aura (Blizzard), Swing, Ammo, Bag Space, bordure ou icône de dispel.
- [ ] Désactive ForeverAuras, réactive WeakAuras Forever, importe les chaînes.
- [ ] Le chat affiche « Converted from ForeverAuras. » et la liste de ce qui n'est pas converti.
- [ ] Chaque aura importée marche comme dans ForeverAuras. Note celles qui diffèrent.

---

## Étape 10 : donjon ou raid (si possible, 30 min)

- [ ] Un vrai combat de boss avec 5 à 10 auras chargées : pas d'erreur, pas de chute de FPS.
- [ ] `/wa pstart encounter`, fais le boss, `/wa pprint` : note les 3 lignes les plus chères.
- [ ] Refais les commandes 1.9 et 1.10 pendant le combat.

---

## Prompt à donner à Claude à la fin

Copie ce bloc, remplis les résultats, colle le tout dans une nouvelle conversation dans ce dossier :

```
Voici les résultats des tests en jeu de WeakAuras Forever, dans l'ordre de TESTS-EN-JEU.md.
Lis TESTS-EN-JEU.md et CHANGES.md pour le contexte.

Étape 1 (valeurs) :
1.1 = ...   1.2 = ...   1.3 = ...   1.4 = ...   1.5 = ...   1.6 = ...
1.7 = ...   1.8 = ...   1.9 = ...   1.10 = ...  1.11 = ...

Étape 6.5 (lien Cooldown Manager, lignes affichées) :
hors combat = ...
en combat = ...
commande 4 = ...

Tests KO (numéro d'étape, ce que j'ai fait, ce que j'ai vu, erreur BugSack complète) :
- ...

Tests non faits :
- ...

Profilage (/wa pprint, 3 lignes les plus chères) :
- ...

Ce que je veux :
1. Corrige les tests KO, du plus grave au moins grave (🔴 d'abord), sans rien ajouter d'autre.
2. Si 1.9 et 1.10 sont true, code le trigger natif « Encounter Timeline » de la phase E, sinon ferme la phase E.
2b. Si l'étape 6.5 montre en combat un ID d'instance lisible, relie les auras secrètes du trigger Aura aux entrées du
    Cooldown Manager pour les reconnaître par ID de sort, avec une aide hors combat qui range les buffs voulus dans
    Tracked Buffs. Sinon, note la limite dans TUTORIAL.md.
3. Utilise wow-api pour toute API non vérifiée et relecteur avant de dire terminé.
4. Mets à jour CHANGES.md et coche dans TESTS-EN-JEU.md ce qui est corrigé.
5. Donne-moi à la fin la liste des tests à refaire en jeu.
```
