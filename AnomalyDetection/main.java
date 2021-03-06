import java.io.*;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.EasyPredictModelWrapper;
import hex.genmodel.easy.prediction.*;
import hex.genmodel.MojoModel;

public class main {
  public static void main(String[] args) throws Exception {
    String modelfile = "GBM_362.zip";
    // String modelfile = "XGBoost_1_AutoML_20190703_181005.zip";
    EasyPredictModelWrapper model = new EasyPredictModelWrapper(MojoModel.load(modelfile));

    RowData row = new RowData();
    row.put("Time_In_a_Day", args[0]);
    row.put("Value", args[1]);
    //row.put("sales_1_month", args[2]);
    //row.put("sales_9_month", args[3]);
    //row.put("local_bo_qty", args[4]);

    //System.out.println("Row: " + row);

    BinomialModelPrediction p = model.predictBinomial(row);
    if (p.label.equals("0")){
	System.out.println("Normal");}
    else{
	System.out.println("Abnormal");
	System.out.print("Check the CPU,mem usage in compute node");
	}
	
    //System.out.println("Label: " + p.label);
    //System.out.print("Class probabilities: ");
    //for (int i = 0; i < p.classProbabilities.length; i++) {
    //  if (i > 0) {
    //System.out.print(",");
    //  }
    //  System.out.print(p.classProbabilities[i]);
    //}
    //System.out.println("");
  }
}
