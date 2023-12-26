class PlotterFont {

    String fontPath;
    float defaultSize = 60;
    float spaceWidth = 44;
    float scale = 1;
    float lineHeight = 80;

     PlotterFont(String _fontPath, float _size) {
        fontPath = _fontPath;
        loadData(_fontPath + "data.json");
        setSize(_size);
     }

    PlotterFont(String _fontPath) {
        fontPath = _fontPath;
        loadData(_fontPath + "data.json");
    }

    void loadShapes() {

    }
    
    void loadData(String _path) {
        JSONObject data = loadJSONObject(_path);
        defaultSize = data.getFloat("defaultSize");
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