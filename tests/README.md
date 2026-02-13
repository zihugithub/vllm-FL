# vllm-FL Test Suite

## Quick Start

```bash
# Run all tests
torchrun --nproc_per_node=8 -m pytest -q -x -p no:warnings tests/

# Run the designated test cases
torchrun --nproc_per_node=8 -m pytest -q -x -p no:warnings tests/test_<name>.py
```

## Directory Structure

```
tests/
├── basic_correctness/                    # Basic functionality correctness tests
├── benchmarks/                           # Performance benchmark tests (throughput, latency, etc.)
├── compile/                              # Compilation and graph optimization tests
├── config/                               # Configuration management tests
├── cuda/                                 # CUDA-specific functionality tests
├── detokenizer/                          # Detokenization strategy tests
├── distributed/                          # Distributed system tests
├── engine/                               # Inference engine core tests
├── entrypoints/                          # Entry points and API service tests
├── evals/                                # Model evaluation tests
├── fastsafetensors_loader/               # FastSafetensors weight loading tests
├── kernels/                              # Low-level kernel operator tests
├── kv_transfer/                          # KV cache transfer and offloading tests
├── lora/                                 # LoRA fine-tuning and adapter tests
├── mistral_tool_use/                     # Mistral model tool calling tests
├── model_executor/                       # Model executor tests
├── models/                               # Model compatibility and functionality tests
├── multimodal/                           # Multimodal tools and component tests
├── plugins/                              # Plugin system test resources
├── plugins_tests/                        # Plugin system integration tests
├── prompts/                              # Test-specific prompt resources
├── quantization/                         # End-to-end quantization tests
├── reasoning/                            # Chain-of-Thought (CoT) and reasoning parser tests
├── runai_model_streamer_test/            # RunAI distributed model streaming load tests
├── samplers/                             # Sampling strategy correctness tests
├── speculative_decoding/                 # Speculative decoding tests
├── standalone_tests/                     # Standalone, dependency-free tests
├── system_messages/                      # System prompt configuration
├── tensorizer_loader/                    # Tensorizer format weight loading tests
├── tokenization/                         # Tokenizer functionality tests
├── tool_use/                             # General tool calling integration tests
├── tools/                                # Core utility function unit tests
├── tpu/                                  # TPU hardware-specific tests
├── transformers_utils/                   # HuggingFace Transformers integration tests
├── utils_/                               # Common utility function unit tests
├── v1/                                   # v1 architecture-specific tests
├── vllm_test_utils/                      # vLLM test utilities
└── weight_loading/                       # Large-scale weight loading stress tests
```

## Adding Tests

### Unit Test
Add test file: `unit_tests/test_<name>.py`
