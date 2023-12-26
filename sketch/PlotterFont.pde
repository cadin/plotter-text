import java.util.Iterator;
import java.util.Set;

class PlotterFont {

	String fontPath;
	float defaultSize = 60;
	float spaceWidth = 44;
	float scale = 1.0f;
	float lineHeight = 80;
	boolean singleCase = true;

	HashMap<String,PShape> shapes = new HashMap<String,PShape>();

	 PlotterFont(String _fontPath, float _size) {
		fontPath = _fontPath;
		loadData(_fontPath + "data.json");
		setSize(_size);
	 }

	PlotterFont(String _fontPath) {
		fontPath = _fontPath;
		loadData(_fontPath + "data.json");
	}

	void loadChars(JSONObject _chars) {
		println(_chars.size());

		Set<String> keysSet = _chars.keys();
		Iterator<String> keys = keysSet.iterator();
		while(keys.hasNext()) {
			String key = keys.next();
			JSONObject charData = _chars.getJSONObject(key);

			PShape shape = loadShape(fontPath + charData.getString("filename"));
			shape.disableStyle();
			shapes.put(key, shape);
			// println(key);
			// println(charData);
		}
	}
	
	void loadData(String _path) {
		JSONObject data = loadJSONObject(_path);

		if(!data.isNull("defaultSize")) {
			defaultSize = data.getFloat("defaultSize");
		}
		if (!data.isNull("spaceWidth")) {
			spaceWidth = data.getFloat("spaceWidth");
		}
		if (!data.isNull("lineHeight")) {
			lineHeight = data.getFloat("lineHeight");
		}
		if (!data.isNull("singleCase")) {
			singleCase = data.getBoolean("singleCase");
		}

		loadChars(data.getJSONObject("chars"));
	}

	void setSize(float _size) {
		scale = _size / defaultSize;
	} 

	float getCharWidth(char _char) {
		return 80;
	}

	void drawChar(char _char) {
		PShape shape = shapes.get(String.valueOf(_char));
		if(shape == null) {
			shape = shapes.get("null");	
		} 

		shape(shape, -20, -20);
	}

	void drawText(String _text) {
		drawText(_text, 0, 0);
	}

	void drawText(String _text, float _x, float _y) {
		float originalStroke = g.strokeWeight;
		pushMatrix();
			translate(_x, _y);
			strokeWeight(originalStroke / scale);
			scale(scale);
			drawString(_text);
		popMatrix();

		strokeWeight(originalStroke);
	}

	protected void drawString(String _text) {
		float lineStartX = 0;
		for (int i = 0; i < _text.length(); i++) {
			char c = _text.charAt(i);
			if(font.singleCase) {
				c = Character.toLowerCase(c);
			}

			if (c == ' ') {
				translate(font.spaceWidth, 0);
				lineStartX -= font.spaceWidth;
			} else if (c == '\n') {
				translate(lineStartX, font.lineHeight);
				lineStartX = 0;
			} else {
				drawChar(c);
				translate(font.getCharWidth(c), 0);
				lineStartX -= font.getCharWidth(c);
			}
		}
	}
}