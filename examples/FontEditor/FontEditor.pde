import controlP5.*;

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
	"you’re yuck zac zeal zigzag zing zodiac zoo",
	
	"AC AT AVA AWA AYA AV AW AY AZ CT CYC FA FE FO KV KW KY LO LV LY NG",
	"OD PA PA PE PO TA TA TE TI TO TR TS TU TY UA VA VA VE VO VR VU",
	"VY WA WO WA WE WR WV WY YS",

    "$1.50 $2.25 $3.00 $4.50 $5.25 $6.00 $7.75 $8.50 $9.25 $0.00",
	"111 222 333 444 555 666 777 888 999 000",
	"4,321 3,210 2,109 1,098 9,876 8,765 7,654 6,543 5,432 4,321",

};

PlotterText plotterText;
boolean cntrlIsDown = false;
boolean shiftIsDown = false;
boolean altIsDown = false;

String currentCharacterKey = "a";
SVGCharacter currentCharacter;
SVGCharacter secondCharacter;
float editorScale = 4;
float editorMargin = 50;
float editorHeight = editorMargin * 2;
int topBarHeight = 20;

int previewLineIndex = 0;
int previewLines = 10;
int previewStroke = 2;

float previewPosition = editorHeight + 50;

final int MODE_POSITION = 0;
final int MODE_KERNING = 1;
final int MODE_LETTERSPACING = 2;
int mode = MODE_POSITION;

ControlP5 cp5;
Textlabel modeLabel;
Textlabel noGlyphLabel;

void setup() {
	size(1440, 800);

	plotterText = new PlotterText("../../fonts/astroTown/", 20);
	pixelDensity(displayDensity());

	currentCharacter = plotterText.characters.get("a");
	secondCharacter = plotterText.characters.get("a");

	editorHeight = plotterText.defaultSize* editorScale + (editorMargin * 2);
	previewPosition = editorHeight + 50 + topBarHeight;

	setupUI();
}

void setupUI() {
	cp5 = new ControlP5(this);

	ButtonBar topBar = cp5.addButtonBar("modeChange")
		.setPosition(0, 0)
		.setSize(400, 20)
		.addItems(split("position kerning letterspacing"," "))
		;
	topBar.changeItem("position","selected",true);

	ButtonBar previewSizeBar = cp5.addButtonBar("previewSize")
		.setPosition(0, previewPosition)
		.setSize(195, 20)
		.addItems(split("small medium large"," "))
		;
	previewSizeBar.changeItem("large","selected",true);

	ButtonBar strokeSizeBar = cp5.addButtonBar("strokeSize")
		.setPosition(200, previewPosition)
		.setSize(200, 20)
		.addItems(split("thin medium thick"," "))
		;
	strokeSizeBar.changeItem("medium","selected",true);

	modeLabel = cp5.addTextlabel("label")
		.setText("ARROW KEYS ADJUST CHARACTER POSITION")
		.setPosition(20,editorHeight + topBarHeight + 10)
		.setColorValue(0)
		;
	noGlyphLabel = cp5.addTextlabel("noGlyph")
		.setText("NO GLYPH")
		.setPosition(100, topBarHeight + editorHeight / 2)
		.setColorValue(100)
		.setVisible(false)
		;
	cp5.addTextlabel("label2")
		.setText("SHIFT OR ALT FOR MACRO/MICRO ADJUSTMENTS")
		.setPosition(20,editorHeight + topBarHeight + 22)
		.setColorValue(150)
		;
	cp5.addTextlabel("label3")
		.setText("PG UP/DOWN CYCLES PREVIEW TEXT")
		.setPosition(20,height - 30)
		.setColorValue(100)
		;

	Button saveButton = cp5.addButton("save")
		.setLabel("SAVE FONT")
		.setPosition(width -100, 0)
		.setSize(100, 20)
		;
	Button loadButton = cp5.addButton("loadGlyph")
		.setLabel("LOAD GLYPH")
		.setPosition(width -205, 0)
		.setSize(100, 20)
		;
}

// BUTTON CALLBACKS
void modeChange(int n) {
	mode = n;
	switch(mode) {
		case MODE_POSITION:
			modeLabel.setText("ARROW KEYS ADJUST CHARACTER POSITION");
			break;
		case MODE_KERNING:
			modeLabel.setText("ARROW KEYS ADJUST KERNING");
			break;
		case MODE_LETTERSPACING:
			modeLabel.setText("ARROW KEYS ADJUST GLOBAL LETTER SPACING");
			break;
	}
}

void loadGlyph() {
	File defaultDirectory;
	String fullPath = sketchPath() + "/" + plotterText.fontPath +"char-" + currentCharacterKey + ".svg";
	try {
		defaultDirectory = new File(fullPath).getCanonicalFile();
	} catch (IOException e) {
		println("Error resolving path: ");
		println(e.getMessage());
		return;
	}

	selectInput("Select glyph for " + currentCharacterKey, "onGlyphSelected", defaultDirectory, this);
}

void save() {
	plotterText.saveData();
}

void strokeSize(int n) {
	int[] sizes = {1, 2, 4};
	previewStroke =  sizes[n];
}

void previewSize(int n) {
	int[] sizes = {10, 15, 20};
	plotterText.setSize( sizes[n] );
}

// Callback for selectInput()
public void onGlyphSelected(File file) {
	if(file == null) return;

	String name = file.getName();
	plotterText.addGlyphForChar(name, currentCharacterKey);
	currentCharacter = plotterText.characters.get(currentCharacterKey);
	if(currentCharacter == null){
		println("Error loading glyph");
	}
}

// DRAWING
void draw() {
	background(255);
	noFill();
	if(mode != MODE_LETTERSPACING) {
		drawEditor();
	}
	drawPreviewText();
	drawUI();
}


void drawEditor() {
	pushMatrix();
		translate(0, 20);
		scale(editorScale);
		noFill();
		drawRulers();
		if(currentCharacter != null) {
			noGlyphLabel.setVisible(false);
			drawCurrentCharacter(currentCharacter);
			if(mode == MODE_KERNING && secondCharacter != null ) {
				drawSecondCharacter(secondCharacter);
			}
		} else {
			noGlyphLabel.setVisible(true);
		}
	popMatrix();
}

// draw some bars. The actual UI is drawn by ControlP5
void drawUI() {
	noStroke();
	fill(150);
	rect(0, 0, width, 20);
	rect(0, previewPosition, width, 20);

	fill(250);
	rect(0, editorHeight + topBarHeight, width, previewPosition - editorHeight - topBarHeight);
	rect(0, height - 40, width, 40);
}

void drawRulers() {
	float margin = editorMargin / editorScale;
	float topRule = margin;
	float bottomRule = margin + plotterText.defaultSize;

	stroke(0, 255, 255);
	strokeWeight(1/editorScale);
	line(0, topRule, width, topRule);
	line(0, bottomRule, width, bottomRule);
	line(margin, 0, margin, plotterText.defaultSize + (margin*2));
	stroke(255, 0, 0);
	if(currentCharacter != null) {
		line(currentCharacter.width + margin, 0, currentCharacter.width + margin, plotterText.defaultSize + (margin*2));	
		if(mouseIsInEditorArea()) {
			stroke(255, 0, 0, 50);
			line(mouseX / editorScale, 0, mouseX / editorScale, plotterText.defaultSize + (margin*2));
		}
	}	
}

void drawLargeCharacter(SVGCharacter character, float x, float y) {
	pushMatrix();
		noFill();
		translate(x, y);
		strokeWeight(6 / editorScale);
		stroke(0);
		character.draw();
	popMatrix();
}

void drawCurrentCharacter(SVGCharacter character) {
	float margin = editorMargin / editorScale;
	drawLargeCharacter(character, margin, margin);
}

void drawSecondCharacter(SVGCharacter character) {
	float margin = editorMargin / editorScale;
	drawLargeCharacter(character, margin + currentCharacter.width + (plotterText.letterSpacing * plotterText.defaultSize) + plotterText.kerningForChars(currentCharacter.key, secondCharacter.key), margin);
}

void drawPreviewText() {
	String sampleText = joinSampleText(previewLineIndex);
	strokeWeight(previewStroke);
	stroke(0);
	plotterText.drawText(sampleText, 10, previewPosition + 40);
}

boolean mouseIsInEditorArea() {
	return mouseY < editorHeight + topBarHeight && mouseY > topBarHeight + editorMargin;
}

String joinSampleText(int startIndex) {
	String joined = "";

	for(int i = startIndex; i < startIndex + previewLines; i++) {
		int index = i % sampleTexts.length;
		joined += sampleTexts[index] + "\n";
	}

	return joined;
}

void mousePressed() {
	if(currentCharacter == null) return;
	if(!mouseIsInEditorArea()) return;
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
	if(mode == MODE_KERNING) {
		if(secondCharacter == null) return;
		plotterText.adjustKerning(currentCharacter.key, secondCharacter.key, amount);
		return;
	} 
	
	if(mode == MODE_LETTERSPACING) {
		plotterText.letterSpacing += amount / 100;
		return;
	} 

	if(currentCharacter != null) {
		currentCharacter.x += amount;
	}
}

void moveVertical(float amount) {
	if(mode != MODE_POSITION) return;

	if(currentCharacter != null) {
		currentCharacter.y += amount;
	}
}

void keyPressed() {

	// CNTRL + S to save
	if(cntrlIsDown && keyCode == 83) { 
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
			break;
		case SHIFT:
			shiftIsDown = true;
			break;
		case ALT:
			altIsDown = true;
			break;
		case LEFT: 
			moveHorizontal(-moveDist);
			break;
		case RIGHT:
			moveHorizontal(moveDist);
			break;
		case UP:
			moveVertical(-moveDist);
			break;
		case DOWN:
			moveVertical(moveDist);
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
		if(mode == MODE_LETTERSPACING) return;
		if(mode == MODE_KERNING) {
			if(secondCharacter == null) {
				secondCharacter = plotterText.characters.get(String.valueOf(key));
				println("Second character: " + key);
			} else {
				secondCharacter = null;
				currentCharacterKey = String.valueOf(key);
				currentCharacter = plotterText.characters.get(String.valueOf(key));
				println("Current character: " + key);
			}
		} else {
			currentCharacterKey = String.valueOf(key);
			currentCharacter = plotterText.characters.get(String.valueOf(key));
			println("Current character: " + key);
		}
	}
}

// this is probably not a complete list
boolean isPrintable(int code) {
	return 
		(code > 47 && code < 58)   || // number keys
		code == 32   ||               // spacebar
		(code > 64 && code < 91)   || // letter keys
		(code > 95 && code < 112)  || // numpad keys
		(code > 43 && code < 62)   || // ;=,-./` (in order)
		(code > 90 && code < 94);   // [\]' (in order)
}