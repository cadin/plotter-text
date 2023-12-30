class SVGCharacter {

    PShape shape;
    float x = 0.0f;
    float y = 0.0f;
    float width = 60.0f;
    String filename;
    String key;
    String fontPath = "";

    SVGCharacter(String fontPath, JSONObject data, String charKey) {
        key = charKey;
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
        
        this.fontPath = fontPath;
    }

    SVGCharacter(String fontPath, String filename, String charKey) {
        key = charKey;
        shape = loadShape(fontPath + filename);
        shape.disableStyle();
        this.fontPath = fontPath;
    }

    JSONObject getData() {
        JSONObject data = new JSONObject();
        data.setFloat("x", x);
        data.setFloat("y", y);
        data.setFloat("width", width);
        data.setString("filename", filename);
        return data;
    }

    void setFilename(String name) {
        filename = name;
        shape = loadShape(fontPath + filename);
        shape.disableStyle();
    }

    void draw() {
        pushMatrix();
        translate(x, y);
        strokeJoin(ROUND);
        noFill();
        shape(shape);
        popMatrix();
    }
}