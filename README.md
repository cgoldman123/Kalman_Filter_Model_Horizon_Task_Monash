# Horizon Model Fitting and Simulation Code

This repository contains MATLAB scripts for fitting and simulating horizon-based decision-making models using behavioral data.

## File Descriptions (in Order of Execution)

1. **main_horizon.m**  
   - **Purpose**: Orchestrates the full pipeline for fitting the horizon model.
   - **Workflow**:
     1. Reads and processes raw behavioral data using `parse_horizon.m` and `merge_horizon.m`.
     2. Saves processed data to the `processed_data` directory.
     3. Calls `fit_extended_model_VB.m` to fit the horizon model using the processed data.
     4. Outputs fitted model parameters to the `fits` directory as timestamped CSV files.

2. **parse_horizon.m**  
   - **Purpose**: Parses raw data files to create structured tables for analysis.
   - **Key Features**:
     - Extracts trial-level information, such as rewards, choices, and reaction times.
     - Structures data into a subject-wise format with game-specific attributes.

3. **merge_horizon.m**  
   - **Purpose**: Aggregates processed tables for all subjects into a single dataset.
   - **Output**: A consolidated table containing all subjects' data, saved as `big_table`.

4. **fit_extended_model_VB.m**  
   - **Purpose**: Fits the extended horizon model using Variational Bayes (VB).
   - **Key Steps**:
     - Loads processed data using `load_horizon_data.m`.
     - Initializes model parameters and structures data for fitting.
     - Fits the model by invoking `horizon_inversion.m`.
     - Computes fit metrics, including exploration behaviors and model accuracy.

5. **load_horizon_data.m**  
   - **Purpose**: Reads processed data and converts it into a structured format for model fitting.
   - **Key Features**:
     - Augments data with z-scored reaction times and reward-related metrics.
     - Creates variables for tracking exploration behaviors (e.g., random and directed exploration).

6. **horizon_inversion.m**  
   - **Purpose**: Implements model inversion using Variational Bayes.
   - **Key Features**:
     - Optimizes model parameters based on free-energy minimization.
     - Returns fitted parameters and free-energy values.

7. **model_KFcond_v2_SMT_CMG.m**  
   - **Purpose**: Simulates decision-making behaviors using a Kalman filter-based model.
   - **Key Features**:
     - Simulates participant choices using the fitted parameters.
     - Evaluates action probabilities for free-choice trials.

## Usage Instructions

1. **Set Up the Environment**  
   - Ensure MATLAB is installed with required toolboxes.  
   - Download and configure [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) if not already installed.  

2. **Run the Pipeline**  
   - Use `main_horizon.m` as the entry point.  
   - Specify the path to raw data files in the `dir_name` variable.  
   - Adjust output paths as needed.  

3. **Outputs**  
   - Processed behavioral data is saved in the `processed_data` folder.  
   - Model fits are saved in the `fits` folder as timestamped CSV files.

## Notes
- The scripts are designed to handle behavioral data in a specific format. Ensure your data aligns with the expected structure.
- Modify the root directory paths in the scripts to match your system configuration.

## Contact
For questions or further assistance, please contact Carter Goldman.
