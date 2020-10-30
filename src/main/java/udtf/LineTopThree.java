package udtf;

import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDTF;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.StructObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;

import java.util.*;

public class LineTopThree extends GenericUDTF {

    @Override
    public StructObjectInspector initialize(StructObjectInspector argOIs)
            throws UDFArgumentException {
        ArrayList<String> list = new ArrayList<String>();
        list.add("top_name");
        list.add("top_value");
        list.add("second_name");
        list.add("second_value");
        list.add("third_name");
        list.add("third_value");
        ArrayList<ObjectInspector> columnType = new ArrayList<ObjectInspector>();
        columnType.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        columnType.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        columnType.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        columnType.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        columnType.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        columnType.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        return ObjectInspectorFactory.getStandardStructObjectInspector(list, columnType);
    }

    public void process(Object[] args) throws HiveException {
        ArrayList<String> res = new ArrayList<String>();
        if (args == null) {
            res.add(null);
            res.add(null);
            res.add(null);
            res.add(null);
            res.add(null);
            res.add(null);

            forward(res);
        } else {
            HashMap<String, Double> map = new HashMap<String, Double>();
            String[] split = args[0].toString().split(",");
            if (split.length == 0) {
                res.add(null);
                res.add(null);
                res.add(null);
                res.add(null);
                res.add(null);
                res.add(null);
                forward(res);
            } else {
                for (String str : split) {
                    String[] key_value = str.split(":");
                    String key = key_value[0];
                    Double value = Double.valueOf(key_value[1]);
                    map.put(key, value);
                }

                ArrayList<Map.Entry<String, Double>> list = new ArrayList<Map.Entry<String, Double>>(map.entrySet());
                Collections.sort(list, new Comparator<Map.Entry<String, Double>>() {
                    public int compare(Map.Entry<String, Double> o1, Map.Entry<String, Double> o2) {
                        return o2.getValue().compareTo(o1.getValue());
                    }
                });


                if (list.size() <= 0) {
                    res.add(null);
                    res.add(null);
                    res.add(null);
                    res.add(null);
                    res.add(null);
                    res.add(null);
                }

                if (list.size() == 1) {
                    res.add(list.get(0).getKey());
                    res.add(String.valueOf(list.get(0).getValue()));
                    res.add(null);
                    res.add(null);
                    res.add(null);
                    res.add(null);
                }

                if (list.size() == 2) {
                    res.add(list.get(0).getKey());
                    res.add(String.valueOf(list.get(0).getValue()));
                    res.add(list.get(1).getKey());
                    res.add(String.valueOf(list.get(1).getValue()));
                    res.add(null);
                    res.add(null);
                }

                if (list.size() >= 3) {
                    res.add(list.get(0).getKey());
                    res.add(String.valueOf(list.get(0).getValue()));
                    res.add(list.get(1).getKey());
                    res.add(String.valueOf(list.get(1).getValue()));
                    res.add(list.get(2).getKey());
                    res.add(String.valueOf(list.get(2).getValue()));
                }

                forward(res);
            }
        }
    }

    public void close() throws HiveException {
    }
}
