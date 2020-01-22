library(data.table)
library(dplyr)
library(h2o)

# Initialize H2O cluster.
h2o.init()

# Get backorder data.
bo.data <- 
    fread("https://github.com/h2oai/h2o-tutorials/raw/master/h2o-world-2017/automl/data/product_backorders.csv")

bo.data <- bo.data %>% 
    # Make response column categorical (factor).
    mutate(went_on_backorder = as.factor(went_on_backorder)) %>% 
    # Reduce set of features for simplicity.
    select(went_on_backorder, national_inv, forecast_3_month, sales_1_month, sales_9_month, local_bo_qty)

# Feature and response columns.
y <- "went_on_backorder"
x <- setdiff(names(bo.data), y)

# Push data to H2O cluster.
bo.h2o <- h2o.splitFrame(
    data = as.h2o(bo.data),
    ratios = .75,
    destination_frames = c("bo-train", "bo-test"),
    seed = 42)

# Run AutoML.
bo.aml <- h2o.automl(
    x = x,
    y = y,
    training_frame = "bo-train",
    validation_frame = "bo-test",
    leaderboard_frame = "bo-test",
    max_models = 10,
    max_runtime_secs = 120,
    seed = 42,
    project_name = "bo-aml")

# Retrieve leader model.
leader.model <- h2o.getModel(bo.aml@leader@model_id)

# Save model as MOJO.
modelfile <- h2o.download_mojo(leader.model, path = ".", get_genmodel_jar = TRUE)

# After this script finishes, create folder "experiments" and copy the model file (zip)
# and h2o-genmodel.jar there. Also put main.java there, replace modelfile in line 9 of main.java with
# the filename of your model, and compile it via ./compile-model.sh.
