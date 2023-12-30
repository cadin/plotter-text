import java.util.Iterator;
import java.util.Set;

class PlotterText {

	/**
	 * path to the font data folder (relative to the sketch folder)
	 */
	String fontPath;

	/**
	 * The default size of the font (height of the SVG glyphs)
	 */
	float defaultSize = 60.0f;

	/**
	 * The width of a space character
	 */
	float spaceWidth = 44;
	
	/**
	 * The scale of the font (defaultSize * scale = actual size)
	 */
	float scale = 1.0f;

	/**
	 * Controls linespacing in multi-line text
	 */
	float lineHeight = 80;

	/**
	 * If true, all characters will be treated as lowercase
	 */
	boolean singleCase = true;

	/**
	 * The name of the font
	 */
	String fontName = "Untitled Font";
	
	/**
	 * The spacing between characters
	 */
	float letterSpacing = 0.3f;

	/**
	 * A map of all the characters in the font
	 */
	HashMap<String, SVGCharacter> characters = new HashMap<String, SVGCharacter>();
	
	/**
	 * A map of all the kerning pairs in the font
	 */
	HashMap<String, Float> kerningPairs = new HashMap<String, Float>();


	/**
	 * Creates a new PlotterText object
	 * @param path The path to the font data folder (relative to the sketch folder)
	 * @param size The display size of the font (height of the SVG glyphs)
	 */
	PlotterText(String path, float size) {
		fontPath = path;
		loadData(fontPath + "data.json");
		setSize(size);
	 }

	/**
	 * Creates a new PlotterText object
	 * @param path The path to the font data folder (relative to the sketch folder)
	 */
	PlotterText(String path) {
		fontPath = path;
		loadData(fontPath + "data.json");
	}

	/**
	 * Adjust the amount of kerning between two characters
	 * @param char1 The first character in the pair
	 * @param char2 The second character in the pair
	 * @param adjustment The amount to adjust the kerning by
	 */
	void adjustKerning(String char1, String char2, float adjustment) {
		String pair = char1 + char2;
		if(singleCase) pair = pair.toLowerCase();
		
		if(kerningPairs.containsKey(pair)) {
			float currentAdjustment = kerningPairs.get(pair);
			kerningPairs.put(pair, currentAdjustment + adjustment);
		} else {
			kerningPairs.put(pair, adjustment);
		}
	}

	/**
	 * Get the amount of kerning between two characters
	 * @param char1 The first character in the pair
	 * @param char2 The second character in the pair
	 * @param adjustment The amount to adjust the kerning by
	 */
	float kerningForChars(String char1, String char2) {
		String pair = char1 + char2;
		if(singleCase) pair = pair.toLowerCase();
		
		if(kerningPairs.containsKey(pair)) {
			return kerningPairs.get(pair);
		}
		return 0;
	}

	/**
	 * Saves the font data to a JSON file
	 */
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

	/**
	 * Sets the display size of the font
	 * @param size The new size of the font (height of the SVG glyphs)
	 */
	void setSize(float size) {
		scale = size / defaultSize;
	} 

	/**
	 * Get the width of the specified character
	 * @param c The character to get the width of
	 */
	float getCharWidth(char c) {
		SVGCharacter character = characters.get(String.valueOf(c));
		if(character != null) {
			return character.width;
		}
		return 60;
	}

	/**
	 * Draws the specified character
	 * @param c The character to draw
	 */
	void drawChar(char c) {
		SVGCharacter character = characters.get(String.valueOf(c));
		if(character != null) {
			character.draw();
		}
	}

	/**
	 * Get the width of the specified string
	 * @param text The string to get the width of
	 */
	float getStringWidth(String text) {
		float maxWidth = 0;
		float lineStartX = 0;
		float lineWidth = 0;
		
		for (int i = 0; i < text.length(); i++) {
			char c = text.charAt(i);
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
				if(i < text.length() - 1) {
					kernDist = kerningForChars(String.valueOf(c), String.valueOf(text.charAt(i + 1)));
				}
				float charWidth = getCharWidth(c) + (letterSpacing * defaultSize) + kernDist;
				lineWidth += charWidth;
			}
		}

		return max(maxWidth, lineWidth) * scale;
	}

	/**
	 * Draws the specified string at the current position
	 * @param text The string to draw
	 */
	void drawText(String text) {
		drawText(text, 0, 0);
	}

	/**
	 * Draws the specified string at the specified position
	 * @param text The string to draw
	 * @param x The x position to draw the string at
	 * @param y The y position to draw the string at
	 */
	void drawText(String text, float x, float y) {
		float originalStroke = g.strokeWeight;
		pushMatrix();
			translate(x, y);
			strokeWeight(originalStroke / scale);
			scale(scale);
			drawString(text);
		popMatrix();

		strokeWeight(originalStroke);
	}

	/**
	 * Add a new SVG glyph to the font
	 * @param filename The filename of the SVG file to load
	 * @param character The character to assign the glyph to
	 */
	void addGlyphForChar(String filename, String character) {
		SVGCharacter svgChar = characters.get(String.valueOf(character));
		if(svgChar == null) {
			svgChar = new SVGCharacter(fontPath, filename, character);
			if(svgChar != null) {
				characters.put(character, svgChar);
			} else {
				println("Error loading glyph at path:");
				println(fontPath + filename);
			}
		} else {
			svgChar.setFilename(filename);
		}

	}

	// Private methods
	// --------------------------------
	private void loadChars(JSONObject chars) {
		Set<String> keysSet = chars.keys();
		Iterator<String> keys = keysSet.iterator();
		while(keys.hasNext()) {
			String key = keys.next();
			JSONObject charData = chars.getJSONObject(key);

			SVGCharacter character = new SVGCharacter(fontPath, charData, key);
			characters.put(key, character);
		}
	}

	private void loadKerningPairs(JSONObject pairs) {
		Set<String> keysSet = pairs.keys();
		Iterator<String> keys = keysSet.iterator();
		while(keys.hasNext()) {
			String key = keys.next();
			float value = pairs.getFloat(key);

			kerningPairs.put(key, value);
		}
	}
	
	private void loadData(String path) {
		JSONObject data = loadJSONObject(path);

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

	private void drawString(String text) {
		float lineStartX = 0;
		
		for (int i = 0; i < text.length(); i++) {
			char c = text.charAt(i);
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
				if(i < text.length() - 1) {
					kernDist = kerningForChars(String.valueOf(c), String.valueOf(text.charAt(i + 1)));
				}
				float charWidth = getCharWidth(c) + (letterSpacing * defaultSize) + kernDist;
				translate(charWidth, 0);
				lineStartX -= charWidth;
			}
		}
	}
}

