class SVGText {

	float defaultSize = 60; // default size for 
	float size;

	float strokeSize = 3.0f;
	PlotterFont font;

	SVGText(String _fontPath, float _size) {
		size = _size;
		font = new PlotterFont(_fontPath, _size);
	}

	void draw(String _txt, float _x, float _y) {
		pushMatrix();
		translate(_x, _y);
		strokeWeight(strokeSize/font.scale);	

		scale(font.scale);
		drawSVGText(_txt);
		popMatrix();

		strokeWeight(strokeSize);
	}

	void drawSVGText(String _txt) {
		for (int i = 0; i < _txt.length(); i++) {
			char c = _txt.charAt(i);
			if(font.singleCase) {
				c = Character.toLowerCase(c);
			}

			if (c == ' ') {
				translate(font.spaceWidth, 0);
			} else if (c == '\n') {
				translate(0, font.lineHeight);
			} else {
				font.drawChar(c);
				translate(font.getCharWidth(c), 0);
			}
		}
	}


}