module main

import time
import tabular
import utils
import linear_regression as lr
import py_plot

import read_xlsx_v

struct OLSRegressionDescription {
    mut:
        dependent_variable string
        model_name string
        method string
        datetime time.Time
        no_of_observations int
        r_squared f64
        f_statistic f64
}


fn main() {
    excel_data := read_xlsx_v.parse('./data/test_data_mv_sample.xlsx')!
    mut input_data := excel_data.clone()

    zero_weight_bias := false

    column_names := excel_data.first()
    input_data.delete(0)

    mut x := [][]f64{len: input_data[0].len - 1, init: []f64{len: input_data.len}}
    mut y := []f64{}

    for mut record in input_data {
        int_record := record.map(it.f64())
        y << int_record[input_data[0].len - 1]
    }

    for idx_i in 0..input_data.len {
        for idx_j in 0..input_data[0].len - 1 {
            x[idx_j][idx_i] = input_data[idx_i][idx_j].f64()
        }
    }

    mut df := tabular.DataFrame.data_frame(x, column_names[0..(column_names.len - 1)])
    mut vec := tabular.Series.series(y, column_names[column_names.len - 1])
    mut vec_x := tabular.Series.series(x[0], 'house_size_sqft')

    println(df)
    println(vec)

    println(utils.fsum(y))
    println(vec.fsum())
    println('')

    println(utils.fmean(y))
    println(vec.fmean())
    println('')

    println(utils.fvariance(y))
    println(vec.fvariance())
    println('')

    println(utils.fcovariance(x[0], y))
    println(vec.fcovariance(mut vec_x))
    println('')

    println(utils.fsum(x[0]))
    println(df.fsum('house_size_sqft'))
    println('')

    println(utils.fmean(x[0]))
    println(df.fmean('house_size_sqft'))
    println('')

    println(utils.fvariance(x[0]))
    println(df.fvariance('house_size_sqft'))
    println('')

    println(utils.fcovariance(x[0], x[1]))
    println(df.fcovariance('house_size_sqft', 'no_of_bedrooms'))
    println('')

    print(df.get('house_size_sqft'))




    // mut model := lr.LinearRegression.init_model(0.0000000001, 500, zero_weight_bias, x.len)
    // model = model.fit_model(x, y)

    // println(model)

    // mut results := OLSRegressionDescription {
    //     dependent_variable: column_names[column_names.len - 1]
    //     model_name: "Simple Linear Regression"
    //     method: "Mean Square Error"
    //     datetime: time.now()
    //     no_of_observations: x.len
    //     r_squared: utils.round(lr.score(y_pred, y))
    // }

    // println(results)
    // println(params)

    // mut plot_data := py_plot.PlotGraph {
    //     slope: params.weights[0]
    //     intercept: params.bias
    //     feature_data: x[0]
    //     target_data: y
    // }

    // py_plot.plot_graph(mut plot_data)
}