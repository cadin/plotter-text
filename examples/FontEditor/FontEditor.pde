// TODO: 
// - make kerning easier (add UI, alt conflicts with alt+arrow)
// - controls for scale (of editor and preview text)
// - build script to bundle classes into single file (with plotterText data?)


// https://typeheist.co/blog/sample-text-for-typeface-character-testing/
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
	"intolerant it’s i’ve jazzy jagged jenga jill joint just kangaroo",

	"kettle kitchen knack koala kooky laboratory landing left letter",
	"likely lilac little loco lolly lover’s luna luxurious lying",
	"master matter metres miss moonlight morph mr mrs ms mummy muster",
	"nasal neanderthal necessarily nine nonsense noon numb oar",
	"obfuscate occult oddly often ogre okay omission ozone parallel",
	"pear picnic pneumonic poppy porous pygmy quantum queen quince",

	"quota radii rafferty rattle reassure resist retiree rice roommate",
	"running sassafras savvy scent scuttle seismic shining shook sieve",
	"sister skink slump snide soup spire stay subject sultana svelte",
	"swiftly tallied tattooed taxed tension the theatre title totally",
	"trekked tsunami tutor tying vacuum variable vent vivid void",
	"vulnerable vying waffle wally warranted water weather whale",

	"withheld worry wurst wysiwyg wyvern xenon xmas yak yeah yip",
	"you’re yuck zac zeal zigzag zing zodiac zoo"
};

PlotterText plotterText;
boolean cntrlIsDown = false;
boolean shiftIsDown = false;
boolean altIsDown = false;

SVGCharacter currentCharacter;
SVGCharacter secondCharacter;
float editorScale = 5;
float editorMargin = 50;
boolean isKerning = false;
int targetChar;

int previewLineIndex = 0;
int previewLines = 12;

void setup() {
	size(1440, 800);
	plotterText = new PlotterText("../../fonts/astroTown/", 20);
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
			drawTargetHighlight();
		}
	}
	popMatrix();
}

void drawRulers() {
	float margin = editorMargin / editorScale;
	stroke(0, 255, 255);
	strokeWeight(1/editorScale);
	line(0, margin, width, margin);
	line(0, plotterText.defaultSize + margin, width, plotterText.defaultSize + margin);
	line(margin, 0, margin, plotterText.defaultSize + (margin*2));
	stroke(255, 0, 0);
	if(currentCharacter != null) {
		line(currentCharacter.width + margin, 0, currentCharacter.width + margin, plotterText.defaultSize + (margin*2));	
	}	
}

void drawTargetHighlight() {
	float margin = editorMargin / editorScale;
	float w;
	float x;

	if(targetChar == 1) {
		w = currentCharacter.width;
		x = margin;
	} else {
		w = secondCharacter.width;
		x = margin + currentCharacter.width + plotterText.letterSpacing + plotterText.kerningForChars(currentCharacter.key, secondCharacter.key);
	}

	pushMatrix();
		fill(0, 255, 255, 100);
		noStroke();
		translate(x, margin + plotterText.defaultSize);
		rect(0, 0, w, 3);
	popMatrix();

	noFill();

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
	translate(margin + currentCharacter.width + (plotterText.letterSpacing * plotterText.defaultSize) + plotterText.kerningForChars(currentCharacter.key, secondCharacter.key), margin);
	character.draw();
	popMatrix();
}

void drawUI() {

}

String joinSampleText(int startIndex) {
	String joined = "";

	for(int i = startIndex; i < startIndex + previewLines; i++) {
		int index = i % sampleTexts.length;
		joined += sampleTexts[index] + "\n";
	}
	
	return joined;

}

void drawSampleText() {
	String sampleText = joinSampleText(previewLineIndex);
	strokeWeight(2);
	stroke(0);
	plotterText.drawText(sampleText, 10, height - 370);
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
		plotterText.adjustKerning(currentCharacter.key, secondCharacter.key, amount);
		return;
	}

	if(currentCharacter != null) {
		currentCharacter.x += amount;
	}
}

void keyPressed() {

	if(cntrlIsDown && keyCode == 83) { // CNTRL + S
		plotterText.saveData();
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
			if(isKerning){
				targetChar ++;
				if(targetChar > 2){
					targetChar = 1;
				}
			}
			break;
		case SHIFT:
			shiftIsDown = true;
			
			break;
		case ALT:
			isKerning = !isKerning;
			if(isKerning) {
				targetChar = 2;
			}
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
		case 33: // PAGE UP
			previewLineIndex -= previewLines;
			if(previewLineIndex < 0) {
				previewLineIndex = sampleTexts.length + previewLineIndex;
			}
			break;

		case 34: // PAGE DOWN
			previewLineIndex += previewLines;
			if(previewLineIndex > sampleTexts.length) {
				previewLineIndex = previewLineIndex - sampleTexts.length;
			}
			break;
	}

	// printable characters
	if(isPrintable(keyCode)) {
		if(isKerning && targetChar == 2) {
			secondCharacter = plotterText.characters.get(String.valueOf(key));
			println("Second character: " + key);
		} else {
			currentCharacter = plotterText.characters.get(String.valueOf(key));
			println("Current character: " + key);
		}
	}
	println(keyCode);

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