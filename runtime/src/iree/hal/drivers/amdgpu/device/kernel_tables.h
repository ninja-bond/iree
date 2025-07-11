// Copyright 2025 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

//===----------------------------------------------------------------------===//
// Blits (blit.h)
//===----------------------------------------------------------------------===//

#define IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_X 32
#define IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Y 1
#define IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Z 1

IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_buffer_fill_x1,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_X,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Y,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Z)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_buffer_fill_x2,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_X,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Y,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Z)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_buffer_fill_x4,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_X,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Y,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Z)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_buffer_fill_x8,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_X,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Y,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Z)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_buffer_fill_block_x16,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_X,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Y,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Z)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_buffer_copy_x1,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_X,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Y,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Z)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_buffer_copy_block_x16,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_X,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Y,
                              IREE_HAL_AMDGPU_BLIT_WORKGROUP_SIZE_Z)

//===----------------------------------------------------------------------===//
// Command buffers (command_buffer.h)
//===----------------------------------------------------------------------===//

// NOTE: these workgroup sizes are guesses and need to be changed.
#if 0
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_cmd_block_issue, 1, 1, 1)
IREE_HAL_AMDGPU_DEVICE_KERNEL(
    iree_hal_amdgpu_device_cmd_dispatch_indirect_update, 1, 1, 1)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_cmd_branch, 1, 1, 1)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_cmd_return, 1, 1, 1)
#endif

//===----------------------------------------------------------------------===//
// Scheduling (scheduler.h)
//===----------------------------------------------------------------------===//

// NOTE: these workgroup sizes are guesses and need to be changed.
#if 0
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_queue_scheduler_initialize,
                              1, 1, 1)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_queue_scheduler_tick, 1, 1,
                              1)
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_queue_retire_entry, 1, 1,
                              1)
#endif

//===----------------------------------------------------------------------===//
// Tracing (tracing.h)
//===----------------------------------------------------------------------===//

#if 0
// NOTE: these workgroup sizes are guesses and need to be changed.
IREE_HAL_AMDGPU_DEVICE_KERNEL(iree_hal_amdgpu_device_trace_buffer_initialize,
                              32, 1, 1)
#endif
