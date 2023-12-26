String testText = "The quick brown fox\njumps over the lazy dog.";

PlotterFont font;

void setup() {
	size(1440, 800);
	font = new PlotterFont("fonts/samaritan/", 20);
	noFill();
}

void draw() {
	background(255);
	strokeWeight(2);
	font.drawText(testText, 10, 10);
}