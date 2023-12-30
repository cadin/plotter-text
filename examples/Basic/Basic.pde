PlotterText pt;

void setup() {
	size(300, 200);
	pt = new PlotterText("../../fonts/astroTown/", 20);
}

void draw() {
	background(255);
	pt.setSize(20);
	strokeWeight(1);
	pt.drawText("Hello", 10, 10);

	pt.setSize(30);
	strokeWeight(3);
	pt.drawTextCentered("World!", width/2, 40);
}
