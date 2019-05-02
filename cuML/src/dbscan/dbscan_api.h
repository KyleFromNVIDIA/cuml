/*
 * Copyright (c) 2019, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#pragma once

#include <cuML_api.h>

#ifdef __cplusplus
extern "C" {
#endif

//Single precision version of DBSCAN fit
cumlError_t cumlSpDbscanFit(cumlHandle_t handle, float* input,
        int n_rows, int n_cols, float eps, int min_pts, int *labels, size_t max_elems);

//Double precision version of DBSCAN fit
cumlError_t cumlDpDbscanFit(cumlHandle_t handle, double *input,
        int n_rows, int n_cols, double eps, int min_pts, int *labels, size_t max_elems);

#ifdef __cplusplus
}
#endif
