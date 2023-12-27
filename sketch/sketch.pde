// String sampleText = "The quick brown fox jumps over the lazy dog.";

String[] sampleTexts = {
	"aaron abduct accidental adjacent afghan after aint anaheim and",
	"anybody although allotted ambidextrous amend announced aqua",
	"arrangement ask aspin ate attitude authorised avery award axolotl",
	"baby baghdad banana batty beeped bent billow bizarre blood bottle",
	"bowwow boyfriend bubbly buzzing byproduct bystander byzantine",
	"cappuccino cattle cent cicero coccyx cooked copyright coyote",
	"croquet cumbersome cycle cylinder czech dabble daddy day divide",
	"don’t dr during dyke each ebb eek elephant emblem ensnare epiphany",
	"esquire etching equine farming feared filler fizzy fjord fluid",
	"foggy foxxy frontal fungal gaggle geared gnome grubby happened",
	"happiness hazy hellish hope hungry hyphen icy i’m impossible",
	"intolerant it’s i’ve jazzy jagged jenga jill joint just kangaroo"
};

PlotterFont font;
boolean cntrlIsDown = false;
boolean shiftIsDown = false;
boolean altIsDown = false;

SVGCharacter currentCharacter;
SVGCharacter secondCharacter;
float editorScale = 5;
float editorMargin = 50;
boolean isKerning = false;

void setup() {
	size(1440, 800);
	font = new PlotterFont("fonts/astroTown/", 20);
	noFill();
}

void draw() {
	background(255);
	drawEditor();
	drawSampleText();
	drawUI();
}

void drawEditor() {
	pushMatrix();
	scale(editorScale);
	drawRulers();
	if(currentCharacter != null) {
		drawCurrentCharacter(currentCharacter);
		if(isKerning && secondCharacter != null ) {
			drawSecondCharacter(secondCharacter);
		}
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

void drawCurrentCharacter(SVGCharacter character) {
	float margin = editorMargin / editorScale;
	pushMatrix();
	stroke(0);
	strokeWeight(6 / editorScale);
	translate(margin, margin);
	character.draw();
	popMatrix();
}

void drawSecondCharacter(SVGCharacter character) {
	float margin = editorMargin / editorScale;
	pushMatrix();
	stroke(0);
	strokeWeight(6 / editorScale);
	translate(margin + currentCharacter.width + font.letterSpacing + font.kerningForChars(currentCharacter.key, secondCharacter.key), margin);
	character.draw();
	popMatrix();
}

void drawUI() {

}

String joinSampleText() {
	String joined = "";
	for(String line : sampleTexts) {
		joined += line + "\n";
	}
	return joined;

}

void drawSampleText() {
	String sampleText = joinSampleText();
	strokeWeight(2);
	stroke(0);
	font.drawText(sampleText, 10, height - 370);
}

void mousePressed() {
	if(currentCharacter == null) return;
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

void moveHorizontal(float amount) {
	if(isKerning && secondCharacter != null) {
		font.adjustKerning(currentCharacter.key, secondCharacter.key, amount);
		return;
	}

	if(currentCharacter != null) {
		currentCharacter.x += amount;
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
			isKerning = !isKerning;
			altIsDown = true;
			break;

		case LEFT: 
			moveHorizontal(-moveDist);
			break;
		case RIGHT:
			moveHorizontal(moveDist);
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

	// printable characters
	if(isPrintable(keyCode)) {
		if(isKerning) {
			secondCharacter = font.characters.get(String.valueOf(key));
			println("Second character: " + key);
		} else {
			currentCharacter = font.characters.get(String.valueOf(key));
			println("Current character: " + key);
		}
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