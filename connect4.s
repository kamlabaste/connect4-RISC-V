# Connect 4
# This program is a derivative version of the game Connect4

.data
	# System calls RARS
	.eqv ReadChar, 12
	.eqv PrintChar, 11
	.eqv PrintString, 4
	.eqv Exit, 10
	
	# Messages displayed to players
	messErreur : .string "Erreur d'entr�e."
	messJoueurXJoue : .string "Le joueur X doit jouer.\n"
	messJoueurOJoue : .string "Le joueur O doit jouer.\n"
	messJoueurXDebord : .string "Le joueur X perd.\n"
	messJoueurODebord : .string "Le joueur O perd.\n"
	messJoueurXGagne : .string "Le joueur X gagne.\n"
	messJoueurOGagne : .string "Le joueur O gagne.\n"
	
	# Initializing the game grid
	grille : .asciz ":",".",".",".",".",".",".",".",":","\n"
		 .asciz ":",".",".",".",".",".",".",".",":","\n"
		 .asciz ":",".",".",".",".",".",".",".",":","\n"
	 	 .asciz ":",".",".",".",".",".",".",".",":","\n"
		 .asciz ":",".",".",".",".",".",".",".",":","\n"
		 .asciz ":",".",".",".",".",".",".",".",":","\n"
		 .eqv grilleLigne, 6
		 .eqv grilleColonne, 10
	
	# Initialization of the line to be added when one of the players overflows
	ligneDebord : .asciz ".",".",".",".",".",".",".",".",".","\n"
		      .eqv ligneDebordLen, 10
	
.text
	la s0, grille	# Initialize the game grid address
	
resetTourJoueurO :
	li s6,0		# Reset the turn of player O who just played
	
joueurX :
	li s5, 1	# Counter indicating that player X is playing
	
	li a7, ReadChar
	ecall
	mv s4, a0
	
	j commande
	
resetTourJoueurX :
	li s5,0		# Reset the turn of player X who just played
	
joueurO :
	li s6, 1	# Counter indicating that player O is playing
		
	li a7, ReadChar
	ecall
	mv s4, a0
		
	j commande

# Game command call list
commande :				
	li t0, 'q'
	beq a0, t0, sortie
	
	li t0, '1'
	beq a0, t0, ajouterJetonColonne
	li t0, '2'
	beq a0, t0, ajouterJetonColonne
	li t0, '3'
	beq a0, t0, ajouterJetonColonne
	li t0, '4'
	beq a0, t0, ajouterJetonColonne
	li t0, '5'
	beq a0, t0, ajouterJetonColonne
	li t0, '6'
	beq a0, t0, ajouterJetonColonne
	li t0, '7'
	beq a0, t0, ajouterJetonColonne

	li t0, 'd'
	beq a0, t0, afficherGrille
	
	li t0, '\n'
	beq a0, t0, sautDeLigne		# Allows you to ignore a line break
		
	j erreurEntree			# If no command is valid, proceed to display an error message and exit the game.

# If a line break is encountered, the current player is asking to re-enter a valid value.
sautDeLigne :
	bgtz s5, joueurX
	bgtz s6, joueurO

# Appel la routine pour ajouter un jeton dans la colonne choisi par les joueurs
ajouterJetonColonne :			
	jal routineAjouterJeton		# Routine pour ajouter un jeton dans une colonne
	j valideQuiGagne		# Apr�s que le jeton est ajout�, cette routine v�rifie si les jetons du joueur courant est align�
		
# V�rifier � chaque tour si un joueur a gagn� en alignant ses jetons
valideQuiGagne :
	lb t1, 0(s3)
	li t0, 'X'
	beq t0, t1, valideJoueurX	# Branche vers la validation de l'alignement des jetons du joueur X
	li t0, 'O'
	beq t0, t1, valideJoueurO	# Branche vers la validation de l'alignement des jetons du joueur O

# Si c'est au tour du joueur X, cela valide si ses jetons sont align�s
valideJoueurX :					
		mv t5, s1				# D�place la ligne courante dans un registre temporaire
		li s7, 1				# Initialise l'indice confirmant l'alignement des jetons
	
	# Valide si les jetons du joueur X sont align�s de haut en bas
	patternBasX :				
		li t4, 4				# Maximum de jetons � aligner
		beq s7, t4, joueurXGagne		# Si 4 jetons X sont align�s, branche vers l'affichage de la grille et l'annonce de la victoire du joueur X 
		li t0, grilleLigne
		addi t5, t5, 1				# Descend d'une ligne
		bge t5, t0, patternGaucheX		# Si on arrive au maximum des lignes de la grille, cela change de chemin de validation
		
		li t0, grilleColonne
		mul s3, t5, t0				# Vers la ligne o� chercher le jeton X
		add s3, s3, s2				# D�place le pointeur vers la case � v�rifier
		slli s3, s3, 1				# D�cale le pointeur pour aligner les bits
		add s3, s3, s0				# Calcul finale de l'adresse de l'�l�ment point�
		
		lb t2, 0(s3)
		li t3, 'O'
		beq t2, t3, patternGaucheX		# Change de chemin de validation, lorsqu'un jeton O est rencontr�
		addi s7, s7, 1				# Incremente si un jeton X adjacent est trouv� dans la direction du chemin de validation
		j patternBasX
	
	# Valide si les jetons du joueur X sont align�s vers la gauche
	patternGaucheX :			
		mv t5, s2				# Initialise l'index du pointeur courant dans un registre temporaire
		li s7, 1				# R�initialise l'indice confirmant l'alignement des jetons car on change de chemin de validation
	
	loopPatternGaucheX :
		li t4, 4
		beq s7, t4, joueurXGagne
		addi t5, t5, -1				# D�place le pointeur d'une case vers la gauche
		li t0, 0
		ble t5, t0, patternDroiteX		# Si le pointeur d�passe la colonne la plus � gauche de la grille, cela change de chemin de validation
		
		li t0, grilleColonne
		mul s3, s1, t0
		add s3, s3, t5
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'O'
		beq t2, t3, patternDroiteX		# Change de chemin de validation, lorsqu'un jeton O est rencontr�
		li t3, '.'
		beq t2, t3, patternDroiteX		# Change de chemin de validation, lorsqu'une case vide est rencontr�
		addi s7, s7, 1
		j loopPatternGaucheX
	
	# Valide si les jetons du joueur X sont align�s vers la droite
	patternDroiteX :
		mv t5, s2				# D�place l'index du pointeur courant dans un registre temporaire
	
	loopPatternDroiteX :
		li t4, 4
		beq s7, t4, joueurXGagne
		addi t5, t5, 1				# D�place le pointeur d'une case vers la droite
		li t0, 8
		bge t5, t0, patternDiagHautDroiteX	# Si le pointeur d�passe la colonne la plus � gauche de la grille, cela change de chemin de validation
		
		li t0, grilleColonne
		mul s3, s1, t0
		add s3, s3, t5
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'O'
		beq t2, t3, patternDiagHautDroiteX
		li t3, '.'
		beq t2, t3, patternDiagHautDroiteX
		addi s7, s7, 1
		j loopPatternDroiteX
	
	# 1�re partie pour valider si les jetons du joueur X sont align�s en diagonale de haut en bas vers la droite � partir du pointeur courant
	patternDiagHautDroiteX :
		mv t5, s1				# Initialise la ligne courante dans un registre temporaire
		mv t6, s2				# Initialise l'index du pointeur courant dans un registre temporaire
		li s7, 1				# R�initialise l'indice confirmant l'alignement des jetons car on change de chemin de validation
	
	loopPatternDiagHautDroiteX :
		li t4, 4
		beq s7, t4, joueurXGagne
		li t0, 0
		addi t5, t5, -1				# Monte d'une ligne
		ble t5, t0, patternDiagBasGaucheX	# Si on arrive au d�l� des lignes de la grille, cela change de chemin de validation
		li t0, 8
		addi t6, t6, 1				# D�place le pointeur d'une case vers la droite
		bge t6, t0, patternDiagBasGaucheX	# Si le pointeur d�passe la colonne la plus � droite de la grille, cela change de chemin de validation
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, t6
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'O'
		beq t2, t3, patternDiagBasGaucheX
		li t3, '.'
		beq t2, t3, patternDiagBasGaucheX
		addi s7, s7, 1
		j loopPatternDiagHautDroiteX
		
	# 2�me partie pour valider si les jetons du joueur X sont align�s en diagonale de haut en bas vers la droite � partir du pointeur courant
	patternDiagBasGaucheX :			
		mv t5, s1				# Initialise la ligne courante dans un registre temporaire
		mv t6, s2				# Initialise l'index du pointeur courant dans un registre temporaire
	
	loopPatternDiagBasGaucheX :
		li t4, 4
		beq s7, t4, joueurXGagne
		li t0, grilleLigne
		addi t5, t5, 1				# Descend d'une ligne
		bge t5, t0, patternDiagHautGaucheX
		li t0, 0
		addi t6, t6, -1				# D�place le pointeur d'une case vers la gauche
		ble t6, t0, patternDiagHautGaucheX
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, t6
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'O'
		beq t2, t3, patternDiagHautGaucheX
		li t3, '.'
		beq t2, t3, patternDiagHautGaucheX
		addi s7, s7, 1
		j loopPatternDiagBasGaucheX
	
	# 1�re partie pour valider si les jetons du joueur X sont align�s en diagonale de haut en bas vers la gauche � partir du pointeur courant
	patternDiagHautGaucheX :
		mv t5, s1			# Initialise la ligne courante dans un registre temporaire
		mv t6, s2			# Initialise l'index du pointeur courant dans un registre temporaire
		li s7, 1			# R�initialise l'indice confirmant l'alignement des jetons
	
	loopPatternDiagHautGaucheX :
		li t4, 4
		beq s7, t4, joueurXGagne
		addi t5, t5, -1			# Monte d'une ligne
		bltz t5, patternDiagBasDroiteX
		li t0, 0
		addi t6, t6, -1			# D�place le pointeur d'une case vers la gauche
		ble t6, t0, patternDiagBasDroiteX
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, t6
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'O'
		beq t2, t3, patternDiagBasDroiteX
		li t3, '.'
		beq t2, t3, patternDiagBasDroiteX
		addi s7, s7, 1
		j loopPatternDiagHautGaucheX
		
	# 2�me partie pour valider si les jetons du joueur X sont align�s en diagonale de haut en bas vers la gauche � partir du pointeur courant
	patternDiagBasDroiteX :
		mv t5, s1			# Initialise la ligne courante dans un registre temporaire
		mv t6, s2			# Initialise l'index du pointeur courant dans un registre temporaire
	
	loopPatternDiagBasDroiteX :
		li t4, 4
		beq s7, t4, joueurXGagne
		li t0, grilleLigne
		addi t5, t5, 1			# Descend d'une ligne
		bge t5, t0, tourSuivant		# Si aucun jetons du joueur X n'est align�s, c'est au joueur O de jouer
		li t0, 8
		addi t6, t6, 1			# D�place le pointeur d'une case vers la droite
		bge t6, t0, tourSuivant
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, t6
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'O'
		beq t2, t3, tourSuivant
		li t3, '.'
		beq t2, t3, tourSuivant
		addi s7, s7, 1
		j loopPatternDiagBasDroiteX	
	
	# Si le joueur X aligne ses jetons, la grille est affich� et le joueur X gagne	
	joueurXGagne :				
		jal routineAfficheGrilleGagnant		# Appel de la routine pour afficher la grille du joueur gagnant X
		j sortie				# Quitte le jeu

# Si c'est au tour du joueur O, cela valide si ses jetons sont align�s
# Le chemin de validation est le m�me que pour le Joueur X, sauf que cette fois, si un jeton X est rencontr�, cela change de chemin de validation ou passe au tour suivant.
valideJoueurO :					
		mv t5, s1
		li s7, 1

	# Valide si les jetons du joueur O sont align�s de haut en bas
	patternBasO :				
		li t4, 4
		beq s7, t4, joueurOGagne	
		li t0, grilleLigne
		addi t5, t5, 1	
		bge t5, t0, patternGaucheO	
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, s2
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'X'
		beq t2, t3, patternGaucheO
		addi s7, s7, 1
		j patternBasO
		
	# Valide si les jetons du joueur O sont align�s vers la gauche
	patternGaucheO :
		mv t5, s2
		li s7, 1
	loopPatternGaucheO :
		li t4, 4
		beq s7, t4, joueurOGagne
		addi t5, t5, -1
		li t0, 0
		ble t5, t0, patternDroiteO
		
		li t0, grilleColonne
		mul s3, s1, t0
		add s3, s3, t5
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'X'
		beq t2, t3, patternDroiteO
		li t3, '.'
		beq t2, t3, patternDroiteO
		addi s7, s7, 1
		j loopPatternGaucheO
	
	# Valide si les jetons du joueur O sont align�s vers la droite
	patternDroiteO :			
		mv t5, s2
	
	loopPatternDroiteO :
		li t4, 4
		beq s7, t4, joueurOGagne
		addi t5, t5, 1
		li t0, 8
		bge t5, t0, patternDiagHautDroiteO
		
		li t0, grilleColonne
		mul s3, s1, t0
		add s3, s3, t5
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'X'
		beq t2, t3, patternDiagHautDroiteO
		li t3, '.'
		beq t2, t3, patternDiagHautDroiteO
		addi s7, s7, 1
		j loopPatternDroiteO
	
	# 1�re partie pour valider si les jetons du joueur O sont align�s en diagonale de haut en bas vers la droite � partir du pointeur courant
	patternDiagHautDroiteO :		
		mv t5, s1
		mv t6, s2			
		li s7, 1			
	
	loopPatternDiagHautDroiteO :
		li t4, 4
		beq s7, t4, joueurOGagne
		li t0, 0
		addi t5, t5, -1
		ble t5, t0, patternDiagBasGaucheO
		li t0, 8
		addi t6, t6, 1
		bge t6, t0, patternDiagBasGaucheO
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, t6
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'X'
		beq t2, t3, patternDiagBasGaucheO
		li t3, '.'
		beq t2, t3, patternDiagBasGaucheO
		addi s7, s7, 1
		j loopPatternDiagHautDroiteO
	
	# 2�me partie pour valider si les jetons du joueur X sont align�s en diagonale de haut en bas vers la droite � partir du pointeur courant
	patternDiagBasGaucheO :			
		mv t5, s1			
		mv t6, s2			
	
	loopPatternDiagBasGaucheO :
		li t4, 4
		beq s7, t4, joueurOGagne
		li t0, grilleLigne
		addi t5, t5, 1
		bge t5, t0, patternDiagHautGaucheO
		li t0, 0
		addi t6, t6, -1
		ble t6, t0, patternDiagHautGaucheO
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, t6
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'X'
		beq t2, t3, patternDiagHautGaucheO
		li t3, '.'
		beq t2, t3, patternDiagHautGaucheO
		addi s7, s7, 1
		j loopPatternDiagBasGaucheO
	
	# 1�re partie pour valider si les jetons du joueur O sont align�s en diagonale de haut en bas vers la gauche � partir du pointeur courant
	patternDiagHautGaucheO :		
		mv t5, s1			
		mv t6, s2			
		li s7, 1			
	
	loopPatternDiagHautGaucheO :
		li t4, 4
		beq s7, t4, joueurOGagne
		addi t5, t5, -1
		bltz t5, patternDiagBasDroiteO
		li t0, 0
		addi t6, t6, -1
		ble t6, t0, patternDiagBasDroiteO
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, t6
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'X'
		beq t2, t3, patternDiagBasDroiteO
		li t3, '.'
		beq t2, t3, patternDiagBasDroiteO
		addi s7, s7, 1
		j loopPatternDiagHautGaucheO
		
	# 2�me partie pour valider si les jetons du joueur O sont align�s en diagonale de haut en bas vers la gauche � partir du pointeur courant
	patternDiagBasDroiteO :			
		mv t5, s1			
		mv t6, s2			
	
	loopPatternDiagBasDroiteO :
		li t4, 4
		beq s7, t4, joueurOGagne
		li t0, grilleLigne
		addi t5, t5, 1
		bge t5, t0, tourSuivant		# Si aucun jetons du joueur O n'est align�s, c'est au joueur X de jouer
		li t0, 8
		addi t6, t6, 1
		bge t6, t0, tourSuivant
		
		li t0, grilleColonne
		mul s3, t5, t0
		add s3, s3, t6
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t3, 'X'
		beq t2, t3, tourSuivant
		li t3, '.'
		beq t2, t3, tourSuivant
		addi s7, s7, 1
		j loopPatternDiagBasDroiteO
	
	# Si le joueur O aligne ses jetons, la grille est affich� et le joueur O gagne
	joueurOGagne :
		jal routineAfficheGrilleGagnant		# Appel de la routine pour afficher la grille du joueur gagnant O
		j sortie				# Quitte le jeu
		
# Affiche la grille de jeu courante et le tour du joueur courant
afficherGrille :			
	li a7, PrintChar
	li a0, '\n'
	ecall
	jal routineAfficherGrille
	bgtz s5, joueurX
	bgtz s6, joueurO

# Au tour du joueur suivant
tourSuivant :				
	bgtz s5, resetTourJoueurX
	bgtz s6, resetTourJoueurO
	
# Affiche un message d'erreur, si la commande jou� n'est pas reconnue, � l'exception du saut de ligne, et quitte le programme.
erreurEntree :				
	li a7, PrintChar
	li a0, '\n'
	ecall

	li a7, PrintString
	la a0, messErreur
	ecall
	
# Quitte le programme
sortie :
	li a7, Exit	
	ecall
	
#### Appel de routines ####

# Routine pour afficher la grille de jeu, lorsque un des joueurs entre la commande 'd'
routineAfficherGrille :
		li s1, 0	# Index ligne courante
	loopLigne :
		li t0, grilleLigne
		bge s1, t0, quelMessAffiche
	
		li s2, 0	# Index colonne courante
	loopColonne :
		li t0, grilleColonne
		bge s2, t0, finLoopColonne
		
		li t0, grilleColonne
		mul s3, s1, t0
		add s3, s3, s2
		slli s3, s3, 1
		add s3, s3, s0
		
		li a7, PrintChar
		lb a0, 0(s3)
		ecall
	
		addi s2, s2, 1
		j loopColonne
		
	finLoopColonne :
		addi s1, s1, 1
		j loopLigne
		
	quelMessAffiche :
		li t0, 'd'
		beq s4, t0, messageAuTourDe	# Branche vers le message du joueur courant qui joue durant ce tour
		
		# Lorsqu'un des joueurs d�borde, cela affiche la grille et un message d�signant le joueur perdant
		bgtz s5, afficheJoueurXDebord	# Si le joueur X d�borde, branche pour afficher son message, puis, quitte le programme
		li a7, PrintString		# Sinon, cela affiche le message du Joueur 0, puis, quitte le programme
		la a0, messJoueurODebord
		ecall
		j finAffiche
		
	afficheJoueurXDebord :
		li a7, PrintString
		la a0, messJoueurXDebord
		ecall
		j finAffiche
		
	messageAuTourDe :
		bgtz s5, messXJoue	# Si c'est au tour du joueur X, cela affiche le message d�signant que c'est son tour		
		li a7, PrintString	# Sinon, cela affiche le message d�signant que c'est au tour du joueur O
		la a0, messJoueurOJoue
		ecall
		
		j finAffiche
		
	messXJoue :
		li a7, PrintString
		la a0, messJoueurXJoue
		ecall
		
	finAffiche :
		ret			# Fin de cette routine

# Routine pour ajouter la ligne qui d�borde
routineAfficheLigneDeborde :
		li s1, 0
		la t3, ligneDebord
		li t0, ligneDebordLen
		mul t4, s1, t0
		add t4, t4, s2
		slli t4, t4, 1
		add t4, t4, t3
		
		bgtz s5, ajouteJetonXDeborde	# Si c'est au tour du joueur X, cela ajoute d'abord son jeton
		li t1, 'O'			# Sinon, cela ajoute jeton du joueur O
		sb t1, 0(t4)			# Ajoute le jeton du joueur O
		
		li a7, PrintChar
		li a0, '\n'
		ecall
		
		j ajouteLigneDebord
		
	ajouteJetonXDeborde :
		li t1, 'X'
		sb t1, 0(t4)			# Ajoute le jeton du joueur X
		
		li a7, PrintChar
		li a0, '\n'
		ecall
	# Ajoute la ligne suppl�mentaire, lorsqu'un des joueurs d�bordent
	ajouteLigneDebord :
		li s2, 0
		
	loopLigneDebord :
		la t3, ligneDebord
		li t0, ligneDebordLen
		bge s2, t0, retourneLigneDebord
		
		li t0, ligneDebordLen
		mul t4, s1, t0
		add t4, t4, s2
		slli t4, t4, 1
		add t4, t4, t3
		
		li a7, PrintChar
		lb a0, 0(t4)
		ecall
	
		addi s2, s2, 1
		j loopLigneDebord
		
	retourneLigneDebord :
		ret				# Fin de cette routine

# Routine pour ajouter le jeton du joueur courant
routineAjouterJeton :
		addi a0, a0, -0x30	# Convertie le charact�re saisie par un des joueurs en d�cimal
		li s1, 5		# Index � partie du bas de la grille 
		mv s2, a0		# Index colonne courante
		
	loop :
		bltz s1, joueurDeborde
		li t0, grilleColonne
		mul s3, s1, t0
		add s3, s3, s2
		slli s3, s3, 1
		add s3, s3, s0
		
		lb t2, 0(s3)
		li t1, 'X'
		beq t1, t2, decrementeLigne
		li t1, 'O'
		beq t1, t2, decrementeLigne
		j ajouteJeton
		
	decrementeLigne :
		addi s1, s1, -1
		j loop
		
	ajouteJeton :
		bgtz s5, ajouteJetonX		# Si c'est au tour du joueur X, cela ajoute son jeton
		li t1, 'O'			# Sinon, cela ajoute le jeton du joueur O
		sb t1, 0(s3)			# Ajoute le jeton du joueur O
		j finAjoutJeton
		
	ajouteJetonX :
		li t1, 'X'
		sb t1, 0(s3)			# Ajoute le jeton du joueur X
		j finAjoutJeton
		
	joueurDeborde :
		jal routineAfficheLigneDeborde	# Appel la routire pour afficher la ligne suppl�mentaire avec le jeton du joueur qui d�borde
		jal routineAfficherGrille	# Appel la routine pour afficher la grille de jeu de base
		j sortie			# Quitte le programme quand un joueur d�borde
		
	finAjoutJeton :
		ret				# Fin de cette routine

# Routine pour afficher la grille de jeu et le joueur gagnant
routineAfficheGrilleGagnant :
		li a7, PrintChar
		li a0, '\n'
		ecall
		
		li s1, 0			# Index ligne courante
		
	loopLigneGagnant :
		li t0, grilleLigne
		bge s1, t0, afficheJoueurGagnant
	
		li s2, 0			# Index colonne courante
		
	loopColonneGagnant :
		li t0, grilleColonne
		bge s2, t0, finLoopColonneGagnant
		
		li t0, grilleColonne
		mul s3, s1, t0
		add s3, s3, s2
		slli s3, s3, 1
		add s3, s3, s0
		
		li a7, PrintChar
		lb a0, 0(s3)
		ecall
	
		addi s2, s2, 1
		j loopColonneGagnant
		
	finLoopColonneGagnant :
		addi s1, s1, 1
		j loopLigneGagnant
		
	afficheJoueurGagnant :
		bgtz s5, afficheXGagne		# Si c'est au tour du Joueur X, le message annonce qu'il est gagnant
		li a7, PrintString		# Sinon le message annonce que le Joueur 0 gagne
		la a0, messJoueurOGagne
		ecall				# Affiche que le joueur O gagne
		j retourneJoueurGagnant		# Saute vers la fin de cette routine
		
	afficheXGagne :
		li a7, PrintString
		la a0, messJoueurXGagne
		ecall				# Affiche que le joueur X gagne
		
	retourneJoueurGagnant :
		ret				# Fin de cette routine
