import java.util.Iterator;
import java.util.Set;

class PlotterText {

	String fontPath;
	float defaultSize = 60.0f;
	float spaceWidth = 44;
	float scale = 1.0f;
	float lineHeight = 80;
	boolean singleCase = true;
	String fontName = "Untitled Font";
	float letterSpacing = 0.3f;

	HashMap<String, SVGCharacter> characters = new HashMap<String, SVGCharacter>();
	HashMap<String, Float> kerningPairs = new HashMap<String, Float>();

	 PlotterText(String _fontPath, float _size) {
		fontPath = _fontPath;
		loadData(_fontPath + "data.json");
		setSize(_size);
	 }

	PlotterText(String _fontPath) {
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

			SVGCharacter character = new SVGCharacter(fontPath, charData, key);
			characters.put(key, character);
		}
	}

	void loadKerningPairs(JSONObject _pairs) {
		Set<String> keysSet = _pairs.keys();
		Iterator<String> keys = keysSet.iterator();
		while(keys.hasNext()) {
			String key = keys.next();
			float value = _pairs.getFloat(key);

			kerningPairs.put(key, value);
		}
	}
	
	void loadData(String _path) {
		JSONObject data = loadJSONObject(_path);

		if (!data.isNull("name")) {
			fontName = data.getString("name");
		}
		if(!data.isNull("defaultSize")) {
			defaultSize = data.getFloat("defaultSize");
			letterSpacing = defaultSize * 0.25f;
		}
		if(!data.isNull("letterSpacing")) {
			letterSpacing = data.getFloat("letterSpacing");
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
		loadKerningPairs(data.getJSONObject("kerningPairs"));
	}

	void adjustKerning(String _char1, String _char2, float _adjustment) {
		String pair = _char1 + _char2;
		if(kerningPairs.containsKey(pair)) {
			float currentAdjustment = kerningPairs.get(pair);
			kerningPairs.put(pair, currentAdjustment + _adjustment);
		} else {
			kerningPairs.put(pair, _adjustment);
		}
	}

	float kerningForChars(String _char1, String _char2) {
		String pair = _char1 + _char2;
		if(kerningPairs.containsKey(pair)) {
			return kerningPairs.get(pair);
		}
		return 0;
	}

	void saveData() {
		println("Saving font data...");
		JSONObject data = new JSONObject();
		data.setString("name", fontName);
		data.setFloat("defaultSize", defaultSize);
		data.setFloat("letterSpacing", letterSpacing);
		data.setFloat("spaceWidth", spaceWidth);
		data.setFloat("lineHeight", lineHeight);
		data.setBoolean("singleCase", singleCase);

		JSONObject chars = new JSONObject();
		Set<String> keysSet = characters.keySet();
		Iterator<String> keys = keysSet.iterator();
		while(keys.hasNext()) {
			String key = keys.next();
			SVGCharacter character = characters.get(key);

			// get the string value of the character (not unicode escaped):
			String charString = String.valueOf(key.charAt(0));

			chars.setJSONObject(charString, character.getData());
		}
		data.setJSONObject("chars", chars);

	
		JSONObject kerningPairsJSON = new JSONObject();
		Set<String> kerningKeysSet = kerningPairs.keySet();
		Iterator<String> kerningKeys = kerningKeysSet.iterator();
		while(kerningKeys.hasNext()) {
			String key = kerningKeys.next();
			float value = kerningPairs.get(key);

			kerningPairsJSON.setFloat(key, value);
		}
		data.setJSONObject("kerningPairs", kerningPairsJSON);

		saveJSONObject(data, fontPath + "data.json");
		println("DONE");
	}

	void setSize(float _size) {
		scale = _size / defaultSize;
	} 

	float getCharWidth(char _char) {
		SVGCharacter character = characters.get(String.valueOf(_char));
		if(character != null) {
			return character.width;
		}
		return 60;
	}

	void drawChar(char _char) {

		SVGCharacter character = characters.get(String.valueOf(_char));
		if(character != null) {
			character.draw();
		}
	}

	float getStringWidth(String _text) {
		float maxWidth = 0;
		float lineStartX = 0;
		float lineWidth = 0;
		
		for (int i = 0; i < _text.length(); i++) {
			char c = _text.charAt(i);
			if(singleCase) {
				c = Character.toLowerCase(c);
			}

			if (c == ' ') {
				lineWidth += spaceWidth;
			} else if (c == '\n') {
				maxWidth = max(maxWidth, lineWidth);
				lineWidth = 0;
			} else {
				float kernDist = 0;
				if(i < _text.length() - 1) {
					kernDist = kerningForChars(String.valueOf(c), String.valueOf(_text.charAt(i + 1)));
				}
				float charWidth = getCharWidth(c) + (letterSpacing * defaultSize) + kernDist;
				lineWidth += charWidth;
			}
		}

		return max(maxWidth, lineWidth) * scale;
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
			if(singleCase) {
				c = Character.toLowerCase(c);
			}

			if (c == ' ') {
				translate(spaceWidth, 0);
				lineStartX -= spaceWidth;
			} else if (c == '\n') {
				translate(lineStartX, lineHeight);
				lineStartX = 0;
			} else {
				drawChar(c);
				float kernDist = 0;
				if(i < _text.length() - 1) {
					kernDist = kerningForChars(String.valueOf(c), String.valueOf(_text.charAt(i + 1)));
				}
				float charWidth = getCharWidth(c) + (letterSpacing * defaultSize) + kernDist;
				translate(charWidth, 0);
				lineStartX -= charWidth;
			}
		}
	}
}

class SVGCharacter {

    PShape shape;
    float x = 0.0f;
    float y = 0.0f;
    float width = 60.0f;
    String filename;
    String key;

    SVGCharacter(String _key, PShape _shape, float _x, float _y, float _width){
        shape = _shape;
        x = _x;
        y = _y;
        width = _width;
        key = _key;
    }

    SVGCharacter(String fontPath, JSONObject data, String _key) {
        key = _key;
        if(!data.isNull("filename")){
            filename = data.getString("filename");
            shape = loadShape(fontPath + filename);
            shape.disableStyle();
        }

        if(!data.isNull("x")){
            x = data.getFloat("x");
        }
        if(!data.isNull("y")){
            y = data.getFloat("y");
        }
        if(!data.isNull("width")){
            width = data.getFloat("width");
        }
        
    }

    JSONObject getData() {
        JSONObject data = new JSONObject();
        data.setFloat("x", x);
        data.setFloat("y", y);
        data.setFloat("width", width);
        data.setString("filename", filename);
        return data;
    }

    void draw() {
        pushMatrix();
        translate(x, y);
        shape(shape);
        popMatrix();
    }
}