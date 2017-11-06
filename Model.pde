//Defines the model

static class Model extends LXModel {
  
  public Model() {
    super(new Fixture());
  }
  
  private static class Fixture extends LXAbstractFixture {
    
   
    private static final int MATRIX_SIZE_X = 8;
    private static final int MATRIX_SIZE_Y = 60;
    private static final float X_SPACING = 10;
    private static final float Y_SPACING = 0.65625;
    
    private Fixture() {
      for (int x = 0; x < MATRIX_SIZE_X; ++x) {
        for (int y = 0; y < MATRIX_SIZE_Y; ++y) {       
            addPoint(new LXPoint(x*X_SPACING, y*Y_SPACING));          
        }
      }
    }
  }
}