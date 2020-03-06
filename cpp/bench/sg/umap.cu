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

#include <cuml/manifold/umap.hpp>
#include <cuml/cuml.hpp>
#include <utility>
#include "benchmark.cuh"

namespace ML {
namespace Bench {
namespace umap {

struct AlgoParams {
  int min_pts;
  double eps;
  size_t max_bytes_per_batch;
};

struct Params {
  DatasetParams data;
  BlobsParams blobs;
  AlgoParams umap;
};

class Umap : public BlobsFixture<float, long> {
 public:
  Umap(const std::string& name, const Params& p)
    : BlobsFixture<float, long>(p.data, p.blobs), uParams(p.umap) {
    this->SetName(name.c_str());
  }

 protected:
  void runBenchmark(::benchmark::State& state) override {
    if (!this->params.rowMajor) {
      state.SkipWithError("Umap only supports row-major inputs");
    }
    auto& handle = *this->handle;
    auto stream = handle.getStream();
    for (auto _ : state) {
      CudaEventTimer timer(handle, state, true, stream);
      fit(handle, this->data.X, yFloat, this->params.nrows, this->params.ncols,
          uParams, embeddings);
    }
  }

  void allocateBuffers(const ::benchmark::State& state) override {
    auto& handle = *this->handle;
    auto allocator = handle.getDeviceAllocator();
    auto stream = handle.getStream();
    yFloat = (float*)allocator->allocate(this->params.nrows * sizeof(float),
                                         stream);
    embeddings = (float*)allocator->allocate(
      this->params.nrows * uParams.n_components * sizeof(float), stream);
  }

  void daallocateBuffers(const ::benchmark::State& state) override {
    auto& handle = *this->handle;
    auto allocator = handle.getDeviceAllocator();
    auto stream = handle.getStream();
    allocator->deallocate(yFloat, this->params.nrows * sizeof(float), stream);
    allocator->deallocate(
      embeddings, this->params.nrows * uParams.n_components * sizeof(float),
      stream);
  }

 private:
  AlgoParams uParams;
  float *yFloat, *embeddings;
};

std::vector<Params> getInputs() {
  std::vector<Params> out;
  Params p;
  p.data.rowMajor = true;
  p.blobs.cluster_std = 1.0;
  p.blobs.shuffle = false;
  p.blobs.center_box_min = -10.0;
  p.blobs.center_box_max = 10.0;
  p.blobs.seed = 12345ULL;
  p.umap.n_components = 4;
  p.umap.n_epochs = 500;
  p.umap.min_dist = 0.9f;
  std::vector<std::pair<int, int>> rowcols = {
    {10000, 500}, {20000, 500}, {40000, 500},
  };
  for (auto& rc : rowcols) {
    p.data.nrows = rc.first;
    p.data.ncols = rc.second;
    out.push_back(p);
  }
  return out;
}

CUML_BENCH_REGISTER(Params, Umap, "blobs", getInputs());

}  // end namespace umap
}  // end namespace Bench
}  // end namespace ML
