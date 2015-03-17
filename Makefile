NVCC=nvcc
NVCC_FLAGS=-lineinfo -O3 -gencode arch=compute_30,code=sm_30

PATCH=patch

STEP0=0_orig
STEP1=1_occu
STEP2=2_shm
STEP3=3_coalesce
STEP4=4_fp
STEP5=5_overlap

SRC_DIR=src
PATCH_DIR=patches

.PHONY: clean step0 step1 step2 step3 step4 step5

step0: stencil$(STEP0)

step1: stencil$(STEP1)

step2: stencil$(STEP2)

step3: stencil$(STEP3)

step4: stencil$(STEP4)

step5: stencil$(STEP5)

$(SRC_DIR)/stencil$(STEP1).cu: $(SRC_DIR)/stencil$(STEP0).cu
	cp $< $@
	$(PATCH) $@ < $(PATCH_DIR)/step$(STEP1).patch

$(SRC_DIR)/stencil$(STEP2).cu: $(SRC_DIR)/stencil$(STEP1).cu
	cp $< $@
	$(PATCH) $@ < $(PATCH_DIR)/step$(STEP2).patch

$(SRC_DIR)/stencil$(STEP3).cu: $(SRC_DIR)/stencil$(STEP2).cu
	cp $< $@
	$(PATCH) $@ < $(PATCH_DIR)/step$(STEP3).patch

$(SRC_DIR)/stencil$(STEP4).cu: $(SRC_DIR)/stencil$(STEP3).cu
	cp $< $@
	$(PATCH) $@ < $(PATCH_DIR)/step$(STEP4).patch

$(SRC_DIR)/stencil$(STEP5).cu: $(SRC_DIR)/stencil$(STEP4).cu
	cp $< $@
	$(PATCH) $@ < $(PATCH_DIR)/step$(STEP5).patch

stencil$(STEP0).cu: $(SRC_DIR)/stencil$(STEP0).cu
	cp $< $@

stencil$(STEP1).cu: $(SRC_DIR)/stencil$(STEP1).cu
	cp $< $@

stencil$(STEP2).cu: $(SRC_DIR)/stencil$(STEP2).cu
	cp $< $@

stencil$(STEP3).cu: $(SRC_DIR)/stencil$(STEP3).cu
	cp $< $@

stencil$(STEP4).cu: $(SRC_DIR)/stencil$(STEP4).cu
	cp $< $@

stencil$(STEP5).cu: $(SRC_DIR)/stencil$(STEP5).cu
	cp $< $@

stencil$(STEP0): stencil$(STEP0).cu
	$(NVCC) $(NVCC_FLAGS) $^ -o $@

stencil$(STEP1): stencil$(STEP1).cu
	$(NVCC) $(NVCC_FLAGS) $^ -o $@

stencil$(STEP2): stencil$(STEP2).cu
	$(NVCC) $(NVCC_FLAGS) $^ -o $@

stencil$(STEP3): stencil$(STEP3).cu
	$(NVCC) $(NVCC_FLAGS) $^ -o $@

stencil$(STEP4): stencil$(STEP4).cu
	$(NVCC) $(NVCC_FLAGS) $^ -o $@

stencil$(STEP5): stencil$(STEP5).cu
	$(NVCC) $(NVCC_FLAGS) $^ -o $@

clean:
	rm -f *.o \
	      stencil$(STEP0).cu stencil$(STEP1).cu stencil$(STEP2).cu stencil$(STEP3).cu stencil$(STEP4).cu stencil$(STEP5).cu \
	      $(SRC_DIR)/stencil$(STEP1).cu $(SRC_DIR)/stencil$(STEP2).cu $(SRC_DIR)/stencil$(STEP3).cu $(SRC_DIR)/stencil$(STEP4).cu $(SRC_DIR)/stencil$(STEP5).cu \
	      stencil$(STEP0) stencil$(STEP1) stencil$(STEP2) stencil$(STEP3) stencil$(STEP4) stencil$(STEP5)
