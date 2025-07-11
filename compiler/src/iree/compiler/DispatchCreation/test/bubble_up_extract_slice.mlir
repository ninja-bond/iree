// RUN: iree-opt --split-input-file --iree-dispatch-creation-bubble-up-expand-shapes --iree-flow-canonicalize --mlir-print-local-scope %s | FileCheck %s

util.func public @bubble_up_extract_rank_reduce(%arg0 : tensor<1024x7x7x2xi8>) -> tensor<1024x7x7xf32>{
  %0 = tensor.empty() : tensor<1024x7x7x2xf32>
  %cst = arith.constant 5.000000e-01 : f32
  %1 = linalg.generic {indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : tensor<1024x7x7x2xi8>) outs(%0 : tensor<1024x7x7x2xf32>) {
  ^bb0(%in: i8, %out: f32):
    %4 = arith.extsi %in : i8 to i32
    %5 = arith.sitofp %4 : i32 to f32
    %6 = arith.mulf %5, %cst : f32
    linalg.yield %6 : f32
  } -> tensor<1024x7x7x2xf32>

  %extracted_slice = tensor.extract_slice %1[0, 0, 0, 1] [1024, 7, 7, 1] [1, 1, 1, 1] : tensor<1024x7x7x2xf32> to tensor<1024x7x7xf32>
  util.return %extracted_slice : tensor<1024x7x7xf32>
}

// CHECK-LABEL:  @bubble_up_extract_rank_reduce
//       CHECK:    %[[EXTRACT:.+]] = tensor.extract_slice
//       CHECK:    %[[GENERIC:.+]] = linalg.generic
//       CHECK:    util.return %[[GENERIC]]

// -----

util.func public @bubble_up_extract(%arg0 : tensor<1024x7x7x2xi8>) -> tensor<1024x7x7x1xf32>{
  %0 = tensor.empty() : tensor<1024x7x7x2xf32>
  %cst = arith.constant 5.000000e-01 : f32
  %1 = linalg.generic {indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : tensor<1024x7x7x2xi8>) outs(%0 : tensor<1024x7x7x2xf32>) {
  ^bb0(%in: i8, %out: f32):
    %4 = arith.extsi %in : i8 to i32
    %5 = arith.sitofp %4 : i32 to f32
    %6 = arith.mulf %5, %cst : f32
    linalg.yield %6 : f32
  } -> tensor<1024x7x7x2xf32>

  %extracted_slice = tensor.extract_slice %1[0, 0, 0, 1] [1024, 7, 7, 1] [1, 1, 1, 1] : tensor<1024x7x7x2xf32> to tensor<1024x7x7x1xf32>
  util.return %extracted_slice : tensor<1024x7x7x1xf32>
}

// CHECK-LABEL:  @bubble_up_extract
//       CHECK:    %[[EXTRACT:.+]] = tensor.extract_slice
//       CHECK:    %[[GENERIC:.+]] = linalg.generic
//       CHECK:    util.return %[[GENERIC]]

// -----

util.func public @bubble_up_extract_multi_input(%arg0 : tensor<1024x7x7x2xi8>, %arg1 : tensor<1024x7x7x2xi8>) -> tensor<1024x7x7x1xf32>{
  %0 = tensor.empty() : tensor<1024x7x7x2xf32>
  %cst = arith.constant 5.000000e-01 : f32
  %1 = linalg.generic {indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0, %arg1 : tensor<1024x7x7x2xi8>, tensor<1024x7x7x2xi8>) outs(%0 : tensor<1024x7x7x2xf32>) {
  ^bb0(%in: i8, %in_0 : i8, %out: f32):
    %4 = arith.extsi %in : i8 to i32
    %5 = arith.sitofp %4 : i32 to f32
    %6 = arith.mulf %5, %cst : f32
    linalg.yield %6 : f32
  } -> tensor<1024x7x7x2xf32>

  %extracted_slice = tensor.extract_slice %1[0, 0, 0, 1] [1024, 7, 7, 1] [1, 1, 1, 1] : tensor<1024x7x7x2xf32> to tensor<1024x7x7x1xf32>
  util.return %extracted_slice : tensor<1024x7x7x1xf32>
}

// CHECK-LABEL:  @bubble_up_extract_multi_input
//  CHECK-SAME:    %[[ARG0:[a-zA-Z0-9]+]]
//  CHECK-SAME:    %[[ARG1:[a-zA-Z0-9]+]]
//   CHECK-DAG:    %[[EXTRACT0:.+]] = tensor.extract_slice %[[ARG0]]
//   CHECK-DAG:    %[[EXTRACT1:.+]] = tensor.extract_slice %[[ARG1]]
//       CHECK:    %[[GENERIC:.+]] = linalg.generic
//  CHECK-SAME:      ins(%[[EXTRACT0]], %[[EXTRACT1]] : tensor<1024x7x7x1xi8>, tensor<1024x7x7x1xi8>)
//       CHECK:    util.return %[[GENERIC]]

// -----

util.func public @bubble_up_extract_with_use(%arg0 : tensor<1024x7x7x2xi8>) -> (tensor<1024x7x7xf32>, tensor<1024x7x7x2xf32>) {
  %0 = tensor.empty() : tensor<1024x7x7x2xf32>
  %cst = arith.constant 5.000000e-01 : f32
  %1 = linalg.generic {indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : tensor<1024x7x7x2xi8>) outs(%0 : tensor<1024x7x7x2xf32>) {
  ^bb0(%in: i8, %out: f32):
    %4 = arith.extsi %in : i8 to i32
    %5 = arith.sitofp %4 : i32 to f32
    %6 = arith.mulf %5, %cst : f32
    linalg.yield %6 : f32
  } -> tensor<1024x7x7x2xf32>

  %extracted_slice = tensor.extract_slice %1[0, 0, 0, 1] [1024, 7, 7, 1] [1, 1, 1, 1] : tensor<1024x7x7x2xf32> to tensor<1024x7x7xf32>
  util.return %extracted_slice, %1 : tensor<1024x7x7xf32>, tensor<1024x7x7x2xf32>
}

// CHECK-LABEL:  @bubble_up_extract_with_use
//  CHECK-SAME:    %[[ARG0:[a-zA-Z0-9]+]]
//   CHECK-DAG:    %[[GENERIC0:.+]] = linalg.generic
//  CHECK-SAME:      ins(%[[ARG0]] : tensor<1024x7x7x2xi8>)
//
//   CHECK-DAG:    %[[EXTRACT0:.+]] = tensor.extract_slice %[[ARG0]]
//   CHECK-DAG:    %[[GENERIC1:.+]] = linalg.generic
//  CHECK-SAME:      ins(%[[EXTRACT0]] : tensor<1024x7x7xi8>)
//       CHECK:    util.return %[[GENERIC1]], %[[GENERIC0]]

// -----

util.func public @bubble_up_extract_fill_multi_use() -> tensor<2x320x130x130xf8E4M3FNUZ> {
  %cst_1 = arith.constant 1.000000e+00 : f8E4M3FNUZ
  %cst_2 = arith.constant 2.000000e+00 : f8E4M3FNUZ
  %1 = tensor.empty() : tensor<2x320x128x128xf8E4M3FNUZ>
  %2 = linalg.fill ins(%cst_2 : f8E4M3FNUZ) outs(%1 : tensor<2x320x128x128xf8E4M3FNUZ>) -> tensor<2x320x128x128xf8E4M3FNUZ>
  %3 = tensor.empty() : tensor<2x320x130x130xf8E4M3FNUZ>
  %4 = linalg.fill ins(%cst_1 : f8E4M3FNUZ) outs(%3 : tensor<2x320x130x130xf8E4M3FNUZ>) -> tensor<2x320x130x130xf8E4M3FNUZ>
  %extracted_slice_1 = tensor.extract_slice %4[0, 0, 1, 0] [2, 320, 128, 130] [1, 1, 1, 1] : tensor<2x320x130x130xf8E4M3FNUZ> to tensor<2x320x128x130xf8E4M3FNUZ>
  %inserted_slice_1 = tensor.insert_slice %2 into %extracted_slice_1[0, 0, 0, 1] [2, 320, 128, 128] [1, 1, 1, 1] : tensor<2x320x128x128xf8E4M3FNUZ> into tensor<2x320x128x130xf8E4M3FNUZ>
  %inserted_slice_2 = tensor.insert_slice %inserted_slice_1 into %4[0, 0, 1, 0] [2, 320, 128, 130] [1, 1, 1, 1] : tensor<2x320x128x130xf8E4M3FNUZ> into tensor<2x320x130x130xf8E4M3FNUZ>
  util.return %inserted_slice_2 : tensor<2x320x130x130xf8E4M3FNUZ>
}

// CHECK-LABEL:  @bubble_up_extract_fill_multi_use
//       CHECK:    %[[FILL1:.+]] = linalg.fill
//       CHECK:    %[[EMPTY1:.+]] = tensor.empty
//       CHECK:    %[[FILL2:.+]] = linalg.fill
//   CHECK-NOT:    %[[SLICE:.+]] = tensor.extract_slice
//       CHECK:    %[[EMPTY2:.+]] = tensor.empty
//       CHECK:    %[[FILL3:.+]] = linalg.fill

// -----

func.func @bubble_up_extract_slice_single_use(%arg0: tensor<131072xi64>, %arg1: tensor<1x1x131072xi64>, %arg2: index) -> tensor<?x?xi1> {
  %0 = tensor.empty() : tensor<1x1x131072x131072xi1>
  %1 = linalg.generic {indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0, %arg1 : tensor<131072xi64>, tensor<1x1x131072xi64>) outs(%0 : tensor<1x1x131072x131072xi1>) {
  ^bb0(%in: i64, %in_0: i64, %out: i1):
    %2 = arith.cmpi sge, %in, %in_0 : i64
    linalg.yield %2 : i1
  } -> tensor<1x1x131072x131072xi1>
  %extracted_slice = tensor.extract_slice %1[0, 0, 0, 0] [1, 1, %arg2, %arg2] [1, 1, 1, 1] : tensor<1x1x131072x131072xi1> to tensor<?x?xi1>
  return %extracted_slice : tensor<?x?xi1>
}
// CHECK-LABEL: func @bubble_up_extract_slice_single_use
//  CHECK-SAME:     %[[ARG0:.+]]: tensor<131072xi64>
//  CHECK-SAME:     %[[ARG1:.+]]: tensor<1x1x131072xi64>
//  CHECK-SAME:     %[[ARG2:.+]]: index
//   CHECK-DAG:   %[[SLICE0:.+]] = tensor.extract_slice %[[ARG0]]
//   CHECK-DAG:   %[[SLICE1:.+]] = tensor.extract_slice %[[ARG1]]
//   CHECK-DAG:   %[[EMPTY:.+]] = tensor.empty(%[[ARG2]], %[[ARG2]])
//       CHECK:   %[[GENERIC:.+]] = linalg.generic
//  CHECK-SAME:       ins(%[[SLICE0]], %[[SLICE1]] :
//  CHECK-SAME:       outs(%[[EMPTY]] :
//       CHECK:   return %[[GENERIC]]

// -----

func.func @bubble_extract_broadcast(%arg0: tensor<1x1x131072xi64>, %arg2: index) -> tensor<?x?xi1> {
  %empty = tensor.empty() : tensor<1x1x131072x131072xi1>
  %0 = linalg.generic {indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d2)>, affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0: tensor<1x1x131072xi64>) outs(%empty: tensor<1x1x131072x131072xi1>) {
  ^bb0(%in: i64, %out: i1):
    %899 = linalg.index 3 : index
    %900 = arith.index_cast %899 : index to i64
    %901 = arith.cmpi sge, %900, %in : i64
    linalg.yield %901 : i1
  } -> tensor<1x1x131072x131072xi1>
  %extracted_slice = tensor.extract_slice %0[0, 0, 0, 0] [1, 1, %arg2, %arg2] [1, 1, 1, 1] : tensor<1x1x131072x131072xi1> to tensor<?x?xi1>
  return %extracted_slice : tensor<?x?xi1>
}
// CHECK-LABEL: func @bubble_extract_broadcast
//  CHECK-SAME:     %[[ARG0:.+]]: tensor<1x1x131072xi64>
//  CHECK-SAME:     %[[ARG2:.+]]: index
//       CHECK:   %[[EXTRACT:.+]] = tensor.extract_slice %[[ARG0]]
//  CHECK-SAME:     tensor<1x1x131072xi64> to tensor<?xi64>
//       CHECK:   %[[GENERIC:.+]] = linalg.generic
//  CHECK-SAME:     ins(%[[EXTRACT]] : tensor<?xi64>)
//       CHECK:   return %[[GENERIC]]

// -----

func.func @bubble_up_extract_of_expand(%arg0: tensor<131072xi64>, %arg1: tensor<131072xi64>, %arg2: index) -> tensor<?x?xi1> {
  %0 = tensor.empty() : tensor<131072x131072xi1>
  %1 = linalg.generic {indexing_maps = [affine_map<(d0, d1) -> (d1)>, affine_map<(d0, d1) -> (d0)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = ["parallel", "parallel"]} ins(%arg0, %arg1 : tensor<131072xi64>, tensor<131072xi64>) outs(%0 : tensor<131072x131072xi1>) {
  ^bb0(%in: i64, %in_0: i64, %out: i1):
    %2 = arith.cmpi sge, %in, %in_0 : i64
    linalg.yield %2 : i1
  } -> tensor<131072x131072xi1>
  %expanded = tensor.expand_shape %1 [[0, 1, 2], [3]] output_shape[1, 1, 131072, 131072] : tensor<131072x131072xi1> into tensor<1x1x131072x131072xi1>
  %extracted_slice = tensor.extract_slice %expanded[0, 0, 0, 0] [1, 1, %arg2, %arg2] [1, 1, 1, 1] : tensor<1x1x131072x131072xi1> to tensor<?x?xi1>
  return %extracted_slice : tensor<?x?xi1>
}
// CHECK-LABEL: func @bubble_up_extract_of_expand
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: tensor<131072xi64>
//  CHECK-SAME:     %[[ARG1:[a-zA-Z0-9]+]]: tensor<131072xi64>
//  CHECK-SAME:     %[[ARG2:.+]]: index
//   CHECK-DAG:   %[[EXPAND1:.+]] = tensor.expand_shape %[[ARG1]]
//   CHECK-DAG:   %[[SLICE0:.+]] = tensor.extract_slice %[[ARG0]]
//   CHECK-DAG:   %[[SLICE1:.+]] = tensor.extract_slice %[[EXPAND1]]
//   CHECK-DAG:   %[[EMPTY:.+]] = tensor.empty(%[[ARG2]], %[[ARG2]])
//       CHECK:   %[[GENERIC:.+]] = linalg.generic
//  CHECK-SAME:       ins(%[[SLICE0]], %[[SLICE1]] :
//  CHECK-SAME:       outs(%[[EMPTY]] :
//       CHECK:   return %[[GENERIC]]

// -----

func.func @bubble_up_expand_of_extract_of_expand(%arg0: tensor<131072xi64>, %arg1: tensor<131072xi64>, %arg2: index, %arg3: index) -> tensor<?x?x?xi1> {
  %0 = tensor.empty() : tensor<131072x131072xi1>
  %1 = linalg.generic {indexing_maps = [affine_map<(d0, d1) -> (d1)>, affine_map<(d0, d1) -> (d0)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = ["parallel", "parallel"]} ins(%arg0, %arg1 : tensor<131072xi64>, tensor<131072xi64>) outs(%0 : tensor<131072x131072xi1>) {
  ^bb0(%in: i64, %in_0: i64, %out: i1):
    %2 = arith.cmpi sge, %in, %in_0 : i64
    linalg.yield %2 : i1
  } -> tensor<131072x131072xi1>
  %expanded = tensor.expand_shape %1 [[0, 1, 2], [3]] output_shape[1, 1, 131072, 131072] : tensor<131072x131072xi1> into tensor<1x1x131072x131072xi1>
  %extracted_slice = tensor.extract_slice %expanded[0, 0, 0, 0] [1, 1, %arg2, %arg2] [1, 1, 1, 1] : tensor<1x1x131072x131072xi1> to tensor<?x?xi1>
  %expanded_0 = tensor.expand_shape %extracted_slice [[0, 1], [2]] output_shape[%arg3, %arg3, %arg2] : tensor<?x?xi1> into tensor<?x?x?xi1>
  return %expanded_0 : tensor<?x?x?xi1>
}
// CHECK-LABEL: func @bubble_up_expand_of_extract_of_expand
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: tensor<131072xi64>
//  CHECK-SAME:     %[[ARG1:[a-zA-Z0-9]+]]: tensor<131072xi64>
//  CHECK-SAME:     %[[ARG2:[a-zA-Z0-9]+]]: index
//  CHECK-SAME:     %[[ARG3:[a-zA-Z0-9]+]]: index
//   CHECK-DAG:   %[[SLICE0:.+]] = tensor.extract_slice %[[ARG0]]
//   CHECK-DAG:   %[[EXPAND1:.+]] = tensor.expand_shape %[[ARG1]]
//   CHECK-DAG:   %[[SLICE1:.+]] = tensor.extract_slice %[[EXPAND1]]
//   CHECK-DAG:   %[[EXPAND2:.+]] = tensor.expand_shape %[[SLICE1]]
//   CHECK-DAG:   %[[EMPTY:.+]] = tensor.empty(%[[ARG3]], %[[ARG3]], %[[ARG2]])
//       CHECK:   %[[GENERIC:.+]] = linalg.generic
//  CHECK-SAME:       ins(%[[SLICE0]], %[[EXPAND2]] :
//  CHECK-SAME:       outs(%[[EMPTY]] :
//       CHECK:   return %[[GENERIC]]

// -----

util.func public @no_bubble_expand_sliced_dim(%arg0 : tensor<1024xf16>) -> (tensor<32x10xf16>) {
  %extracted_slice = tensor.extract_slice %arg0[0] [320] [1] : tensor<1024xf16> to tensor<320xf16>
  %expanded = tensor.expand_shape %extracted_slice[[0, 1]] output_shape [32, 10] : tensor<320xf16> into tensor<32x10xf16>
  util.return %expanded : tensor<32x10xf16>
}
// CHECK-LABEL: util.func public @no_bubble_expand_sliced_dim
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: tensor
//       CHECK:   %[[EXTRACT:.+]] = tensor.extract_slice %[[ARG0]]
//       CHECK:   %[[EXPAND:.+]] = tensor.expand_shape %[[EXTRACT]]

// -----

util.func public @no_bubble_slice_dynamic(%arg0 : tensor<?xf16>, %val : index) -> (tensor<32x?xf16>) {
  %extracted_slice = tensor.extract_slice %arg0[0] [%val] [1] : tensor<?xf16> to tensor<?xf16>
  %cst32 = arith.constant 32 : index
  %div = arith.divsi %val, %cst32 : index
  %expanded_239 = tensor.expand_shape %extracted_slice[[0, 1]] output_shape [32, %div] : tensor<?xf16> into tensor<32x?xf16>
  util.return %expanded_239 : tensor<32x?xf16>
}
// CHECK-LABEL: util.func public @no_bubble_slice_dynamic
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: tensor
//       CHECK:   %[[EXTRACT:.+]] = tensor.extract_slice %[[ARG0]]
//       CHECK:   %[[EXPAND:.+]] = tensor.expand_shape %[[EXTRACT]]

// -----

util.func public @bubble_slice_dynamic(%arg0 : tensor<?x10x128xf16>, %val : index) -> (tensor<?x5x2x16xf16>) {
  %extracted_slice = tensor.extract_slice %arg0[0, 0, 0] [%val, 10, 16] [1, 1, 1] : tensor<?x10x128xf16> to tensor<?x10x16xf16>
  %expanded = tensor.expand_shape %extracted_slice[[0], [1, 2], [3]] output_shape [%val, 5, 2, 16] : tensor<?x10x16xf16> into tensor<?x5x2x16xf16>
  util.return %expanded : tensor<?x5x2x16xf16>
}
// CHECK-LABEL: util.func public @bubble_slice_dynamic
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: tensor
//  CHECK-SAME:     %[[ARG1:[a-zA-Z0-9]+]]: index
//       CHECK:   %[[CST0:.+]] = arith.constant 0
//       CHECK:   %[[DIM:.+]] = tensor.dim %[[ARG0]], %[[CST0]]
//       CHECK:   %[[EXPAND:.+]] = tensor.expand_shape %[[ARG0]]
//  CHECK-SAME:     output_shape [%[[DIM]], 5, 2, 128]
//       CHECK:   %[[EXTRACT:.+]] = tensor.extract_slice %[[EXPAND]]
//  CHECK-SAME:     [0, 0, 0, 0] [%[[ARG1]], 5, 2, 16] [1, 1, 1, 1]

// -----

util.func public @bubble_expand_rank_reducing_inner(%arg0 : tensor<1024x10xf16>) -> (tensor<32x32xf16>) {
  %extracted_slice = tensor.extract_slice %arg0[0, 0] [1024, 1] [1, 1] : tensor<1024x10xf16> to tensor<1024xf16>
  %expanded = tensor.expand_shape %extracted_slice[[0, 1]] output_shape [32, 32] : tensor<1024xf16> into tensor<32x32xf16>
  util.return %expanded : tensor<32x32xf16>
}
// CHECK-LABEL: util.func public @bubble_expand_rank_reducing_inner
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: tensor
//       CHECK:   %[[EXPAND:.+]] = tensor.expand_shape %[[ARG0]]
//  CHECK-SAME:     tensor<1024x10xf16> into tensor<32x32x10xf16>
//       CHECK:   %[[EXTRACT:.+]] = tensor.extract_slice %[[EXPAND]]
//  CHECK-SAME:     tensor<32x32x10xf16> to tensor<32x32xf16>

// -----

util.func public @bubble_expand_rank_reducing_outer(%arg0 : tensor<10x1024xf16>) -> (tensor<32x32xf16>) {
  %extracted_slice = tensor.extract_slice %arg0[0, 0] [1, 1024] [1, 1] : tensor<10x1024xf16> to tensor<1024xf16>
  %expanded = tensor.expand_shape %extracted_slice[[0, 1]] output_shape [32, 32] : tensor<1024xf16> into tensor<32x32xf16>
  util.return %expanded : tensor<32x32xf16>
}
// CHECK-LABEL: util.func public @bubble_expand_rank_reducing_outer
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: tensor
//       CHECK:   %[[EXPAND:.+]] = tensor.expand_shape %[[ARG0]]
//  CHECK-SAME:     tensor<10x1024xf16> into tensor<10x32x32xf16>
//       CHECK:   %[[EXTRACT:.+]] = tensor.extract_slice %[[EXPAND]]
//  CHECK-SAME:     tensor<10x32x32xf16> to tensor<32x32xf16>

// -----

util.func public @bubble_dynamic_rank_reducing(%arg0: tensor<?x32x2x8x32x128xf8E4M3FNUZ>, %arg1: index) -> tensor<?x8x32x2x64xf8E4M3FNUZ> {
  %extracted_slice = tensor.extract_slice %arg0[0, 31, 0, 0, 0, 0] [%arg1, 1, 1, 8, 32, 128] [1, 1, 1, 1, 1, 1] : tensor<?x32x2x8x32x128xf8E4M3FNUZ> to tensor<?x8x32x128xf8E4M3FNUZ>
  %expanded = tensor.expand_shape %extracted_slice [[0], [1], [2], [3, 4]] output_shape [%arg1, 8, 32, 2, 64] : tensor<?x8x32x128xf8E4M3FNUZ> into tensor<?x8x32x2x64xf8E4M3FNUZ>
  util.return %expanded : tensor<?x8x32x2x64xf8E4M3FNUZ>
}
// CHECK-LABEL: util.func public @bubble_dynamic_rank_reducing
//  CHECK-SAME:     %[[ARG0:[a-zA-Z0-9]+]]: tensor
//  CHECK-SAME:     %[[ARG1:[a-zA-Z0-9]+]]: index
//       CHECK:   %[[CST0:.+]] = arith.constant 0
//       CHECK:   %[[DIM:.+]] = tensor.dim %[[ARG0]], %[[CST0]]
//       CHECK:   %[[EXPAND:.+]] = tensor.expand_shape %[[ARG0]]
//  CHECK-SAME:     output_shape [%[[DIM]], 32, 2, 8, 32, 2, 64]
//       CHECK:   %[[EXTRACT:.+]] = tensor.extract_slice %[[EXPAND]]
//  CHECK-SAME:     [0, 31, 0, 0, 0, 0, 0]
//  CHECK-SAME:     [%[[ARG1]], 1, 1, 8, 32, 2, 64]
//  CHECK-SAME:     [1, 1, 1, 1, 1, 1, 1]
