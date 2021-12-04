package udaf;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.hive.ql.exec.UDFArgumentTypeException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.parse.SemanticException;
import org.apache.hadoop.hive.ql.udf.generic.AbstractGenericUDAFResolver;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDAFEvaluator;
import org.apache.hadoop.hive.serde2.objectinspector.*;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.*;
import org.apache.hadoop.hive.serde2.typeinfo.PrimitiveTypeInfo;
import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;

import java.util.ArrayList;

/**
 * @author wangjingdong
 * @date 2021/12/3 10:27
 * @Copyright © 云粒智慧 2018
 */
public class LastPersonIntoElevator extends AbstractGenericUDAFResolver {
    private static Log LOG = LogFactory.getLog(LastPersonIntoElevator.class);

    @Override
    public GenericUDAFEvaluator getEvaluator(TypeInfo[] parameters) throws SemanticException {
        if (parameters.length != 3) {
            throw new UDFArgumentTypeException(parameters.length - 1,
                    "Exactly three arguments are expected.");
        }

        if (parameters[0].getCategory() != ObjectInspector.Category.PRIMITIVE) {
            throw new UDFArgumentTypeException(0,
                    "Only primitive type arguments are accepted but "
                            + parameters[0].getTypeName() + " is passed.");
        }

        if (parameters[1].getCategory() != ObjectInspector.Category.PRIMITIVE) {
            throw new UDFArgumentTypeException(1,
                    "Only primitive type arguments are accepted but "
                            + parameters[1].getTypeName() + " is passed.");
        }

        if (parameters[2].getCategory() != ObjectInspector.Category.PRIMITIVE) {
            throw new UDFArgumentTypeException(2,
                    "Only primitive type arguments are accepted but "
                            + parameters[2].getTypeName() + " is passed.");
        }

        switch (((PrimitiveTypeInfo) parameters[0]).getPrimitiveCategory()) {
            case BYTE:
            case SHORT:
            case INT:
            case LONG:
            case FLOAT:
            case DOUBLE:
            case TIMESTAMP:
            case DECIMAL:
            case STRING:
                switch (((PrimitiveTypeInfo) parameters[1]).getPrimitiveCategory()) {
                    case BYTE:
                    case SHORT:
                    case INT:
                        switch (((PrimitiveTypeInfo) parameters[2]).getPrimitiveCategory()) {
                            case BYTE:
                            case SHORT:
                            case INT:
                                return new LastPersonIntoEvaluator();
                            case LONG:
                            case FLOAT:
                            case DOUBLE:
                            case TIMESTAMP:
                            case DECIMAL:
                            case STRING:
                            case BOOLEAN:
                            case DATE:
                            default:
                                throw new UDFArgumentTypeException(2,
                                        "Only int type arguments are accepted but "
                                                + parameters[2].getTypeName() + " is passed.");
                        }
                    case LONG:
                    case FLOAT:
                    case DOUBLE:
                    case TIMESTAMP:
                    case DECIMAL:
                    case STRING:
                    case BOOLEAN:
                    case DATE:
                    default:
                        throw new UDFArgumentTypeException(1,
                                "Only int type arguments are accepted but "
                                        + parameters[1].getTypeName() + " is passed.");
                }
            case BOOLEAN:
            case DATE:
            default:
                throw new UDFArgumentTypeException(0,
                        "Only string type arguments are accepted but "
                                + parameters[0].getTypeName() + " is passed.");
        }
    }

    public static class LastPersonIntoEvaluator extends GenericUDAFEvaluator {
        // For PARTIAL1 and COMPLETE
        private PrimitiveObjectInspector nameInputOI;
        private PrimitiveObjectInspector weightInputOI;
        private PrimitiveObjectInspector turnInputOI;

        // For PARTIAL2 and FINAL
        private transient StructObjectInspector soi;
        private transient StructField nameField;
        private transient StructField weightField;
        private transient StructField turnField;
        private StringObjectInspector nameFieldOI;
        private IntObjectInspector weightFieldOI;
        private IntObjectInspector turnFieldOI;

        // For PARTIAL1 and PARTIAL2
        private Object[] partialResult;

        // For FINAL and COMPLETE
        private Text result;

        static class LastPersonAgg extends AbstractAggregationBuffer {
            String name;
            int weight;
            int turn;
        }

        @Override
        public ObjectInspector init(Mode mode, ObjectInspector[] parameters) throws HiveException {
            super.init(mode, parameters);

            // init input
            if (mode == Mode.PARTIAL1 || mode == Mode.COMPLETE) {
                assert (parameters.length == 3);
                nameInputOI = (PrimitiveObjectInspector) parameters[0];
                weightInputOI = (PrimitiveObjectInspector) parameters[1];
                turnInputOI = (PrimitiveObjectInspector) parameters[2];
            } else {
                assert (parameters.length == 1);
                soi = (StructObjectInspector) parameters[0];

                nameField = soi.getStructFieldRef("person_name");
                weightField = soi.getStructFieldRef("weight");
                turnField = soi.getStructFieldRef("turn");

                nameFieldOI = (StringObjectInspector) nameField.getFieldObjectInspector();
                weightFieldOI = (IntObjectInspector) weightField.getFieldObjectInspector();
                turnFieldOI = (IntObjectInspector) turnField.getFieldObjectInspector();
            }

            // init output
            if (mode == Mode.PARTIAL1 || mode == Mode.PARTIAL2) {
                // The output of a partial aggregation is a struct.

                ArrayList<ObjectInspector> foi = new ArrayList<ObjectInspector>();

                foi.add(PrimitiveObjectInspectorFactory.writableStringObjectInspector);
                foi.add(PrimitiveObjectInspectorFactory.writableIntObjectInspector);
                foi.add(PrimitiveObjectInspectorFactory.writableIntObjectInspector);

                ArrayList<String> fname = new ArrayList<String>();
                fname.add("person_name");
                fname.add("weight");
                fname.add("turn");

                partialResult = new Object[3];
                partialResult[0] = new Text();
                partialResult[1] = new IntWritable(0);
                partialResult[2] = new IntWritable(0);

                return ObjectInspectorFactory.getStandardStructObjectInspector(fname, foi);

            } else {
                this.result = new Text();
                return PrimitiveObjectInspectorFactory.writableStringObjectInspector;
            }
        }

        public AggregationBuffer getNewAggregationBuffer() throws HiveException {
            LastPersonAgg agg = new LastPersonAgg();
            reset(agg);
            return agg;
        }

        public void reset(AggregationBuffer agg) throws HiveException {
            LastPersonAgg myagg = (LastPersonAgg) agg;
            myagg.name = "";
            myagg.weight = 0;
            myagg.turn = 0;
        }

        public void iterate(AggregationBuffer agg, Object[] parameters) throws HiveException {
            assert (parameters.length == 3);
            Object pname = parameters[0];
            Object pweight = parameters[1];
            Object pturn = parameters[2];
            if (pname != null && pweight != null && pturn != null) {
                LastPersonAgg myagg = (LastPersonAgg) agg;
                String vname = PrimitiveObjectInspectorUtils.getString(pname, nameInputOI);
                LOG.info(vname);
                int vweight = PrimitiveObjectInspectorUtils.getInt(pweight, weightInputOI);
                int vturn = PrimitiveObjectInspectorUtils.getInt(pturn, turnInputOI);
                myagg.weight += vweight;
                if (myagg.weight > 1000) {
                    myagg.weight -= vweight;
                    myagg.turn = vturn + 1;
                } else {
                    myagg.name = vname;
                }
                LOG.info(myagg.name);
            }
        }

        public Object terminatePartial(AggregationBuffer agg) throws HiveException {
            LOG.info("terminatePartial----------------------");
            LastPersonAgg myagg = (LastPersonAgg) agg;
            ((Text) partialResult[0]).set(myagg.name);
            ((IntWritable) partialResult[1]).set(myagg.weight);
            ((IntWritable) partialResult[2]).set(myagg.turn);
            return partialResult;
        }

        public void merge(AggregationBuffer agg, Object partial) throws HiveException {
            LOG.info("merge-----------------------------------");
            // 在只有一个mapper任务的情况下，agg为空，partial为mapper任务terminatePartial方法返回的结果。
            // 在这种场景下，mapper任务必须为1个，并且trun字段需要从小到大排列。
            if (partial != null) {
                LastPersonAgg myagg = (LastPersonAgg) agg;
                LOG.info(myagg.name);
                LOG.info(myagg.weight);
                LOG.info(myagg.turn);

                Object partialName = soi.getStructFieldData(partial, nameField);
                Object partialWeight = soi.getStructFieldData(partial, weightField);
                Object partialTurn = soi.getStructFieldData(partial, turnField);
                if (myagg.name.equals("")) {
                    myagg.name = nameFieldOI.getPrimitiveJavaObject(partialName);
                    myagg.weight = weightFieldOI.get(partialWeight);
                    myagg.turn = turnFieldOI.get(partialTurn);
                }
                LOG.info(partialName);
                LOG.info(partialWeight);
                LOG.info(partialTurn);
            }
        }

        public Object terminate(AggregationBuffer agg) throws HiveException {
            LOG.info("terminate--------------");
            LastPersonAgg myagg = (LastPersonAgg) agg;
            result.set(myagg.name);
            return result;
        }
    }
}