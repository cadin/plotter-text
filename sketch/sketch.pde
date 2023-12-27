String sampleText = "The quick brown fox\njumps over the lazy dog.";

PlotterFont font;
boolean cntrlIsDown = false;
boolean shiftIsDown = false;
boolean altIsDown = false;

SVGCharacter currentCharacter;
float editorScale = 5;
float editorMargin = 50;

void setup() {
	size(1440, 800);
	font = new PlotterFont("fonts/astroTown/", 20);
	noFill();
}

void draw() {
	background(255);
	drawEditor();
	drawSampleText();
}

void drawEditor() {
	pushMatrix();
	scale(editorScale);
	drawRulers();
	if(currentCharacter != null) {
		drawLargeCharacter(currentCharacter);
	}
	popMatrix();
}

void drawRulers() {
	float margin = editorMargin / editorScale;
	stroke(0, 255, 255);
	strokeWeight(1/editorScale);
	line(0, margin, width, margin);
	line(0, font.defaultSize + margin, width, font.defaultSize + margin);
	line(margin, 0, margin, font.defaultSize + (margin*2));
	stroke(255, 0, 0);
	if(currentCharacter != null) {
		line(currentCharacter.width + margin, 0, currentCharacter.width + margin, font.defaultSize + (margin*2));	
	}	
}

void drawLargeCharacter(SVGCharacter character) {
	float margin = editorMargin / editorScale;
	pushMatrix();
	stroke(0);
	strokeWeight(6 / editorScale);
	translate(margin, margin);
	character.draw();
	popMatrix();
}

void drawSampleText() {
	strokeWeight(2);
	stroke(0);
	font.drawText(sampleText, 10, height - 100);
}

void mousePressed() {
	float charWidth = mouseX / editorScale - editorMargin / editorScale;
	currentCharacter.width = charWidth;
}

void keyReleased() {
	switch(keyCode) {
		case CONTROL:
			cntrlIsDown = false;
			break;
		case SHIFT:
			shiftIsDown = false;
			break;
		case ALT:
			altIsDown = false;
			break;
	}
}

void keyPressed() {

	if(cntrlIsDown && keyCode == 83) { // CNTRL + S
		font.saveData();
		return;
	}

	float moveDist = 1;
	if(shiftIsDown) {
		moveDist = 10;
	} else if(altIsDown) {
		moveDist = 0.1;
	}

	switch(keyCode) {
		case CONTROL:
			cntrlIsDown = true;
			break;
		case SHIFT:
			shiftIsDown = true;
			break;
		case ALT:
			altIsDown = true;
			break;

		case LEFT: 
			if(currentCharacter != null) {
				currentCharacter.x -= moveDist;
			}
			break;
		case RIGHT:
			if(currentCharacter != null) {
				currentCharacter.x += moveDist;
			}
			break;
		case UP:
			if(currentCharacter != null) {
				currentCharacter.y -= moveDist;
			}
			break;
		case DOWN:
			if(currentCharacter != null) {
				currentCharacter.y += moveDist;
			}

			break;
	}


	println(keyCode);
	// printable characters
	if(isPrintable(keyCode)) {
		currentCharacter = font.characters.get(String.valueOf(key));
		println("Current character: " + key);
	}


}

boolean isPrintable(int code) {
	return 
		(code > 47 && code < 58)   || // number keys
		code == 32   ||               // spacebar
		(code > 64 && code < 91)   || // letter keys
		(code > 95 && code < 112)  || // numpad keys
		(code > 43 && code < 62)   || // ;=,-./` (in order)
		(code > 90 && code < 94);   // [\]' (in order)
}