import java.util.Iterator;
import java.util.Set;

class PlotterFont {

	String fontPath;
	float defaultSize = 60;
	float spaceWidth = 44;
	float scale = 1;
	float lineHeight = 80;

	PShape[] shapes;

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

		// iterate over the keys in the JSONObject 
		Set<String> keysSet = _chars.keys();
		Iterator<String> keys = keysSet.iterator();
		while(keys.hasNext()) {
			String key = keys.next();
			JSONObject charData = _chars.getJSONObject(key);
			println(key);
			println(charData);
		}
	}
	
	void loadData(String _path) {
		JSONObject data = loadJSONObject(_path);
		defaultSize = data.getFloat("defaultSize");
		if (!data.isNull("spaceWidth")) {
			spaceWidth = data.getFloat("spaceWidth");
		}
		if (!data.isNull("lineHeight")) {
			lineHeight = data.getFloat("lineHeight");
		}

		loadChars(data.getJSONObject("chars"));
	}

	void setSize(float _size) {
		scale = _size / defaultSize;
	} 

	float getCharWidth(char _char) {
		return 60;
	}

	void drawChar(char _char) {
		rect(0, 0, defaultSize, defaultSize);
	}
}