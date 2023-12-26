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
		return 80;
	}

	void drawChar(char _char) {
		PShape shape = shapes.get(String.valueOf(_char));
		if(shape != null) {
		
			shape(shape, -20, -20);
		} else {
			rect(0, 0, getCharWidth(_char), defaultSize);
		}
	}
}