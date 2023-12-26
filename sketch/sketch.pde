String testText = "The quick brown fox jumps over the lazy dog.";

SVGText svgText;

void setup() {
	size(1440, 800);
	svgText = new SVGText("fonts/samaritan/", 20);
	noFill();
}

void draw() {
	background(255);
	svgText.draw(testText, 10, 10);
}