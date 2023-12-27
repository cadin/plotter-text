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