#include <iostream>
#include <vector>
#include "tensorflow/cc/client/client_session.h"
#include "tensorflow/cc/ops/standard_ops.h"

int main() {

    using namespace tensorflow;
    using namespace tensorflow::ops;
    Scope root = Scope::NewRootScope();

    auto A = Const(root, {{1.f, 2.f}, {3.f, 4.f}});
    auto b = Const(root, {{5.f, 6.f}});
    auto x = MatMul(root.WithOpName("v"), A, b, MatMul::TransposeB(true));
    std::vector<Tensor> outputs;

    std::unique_ptr<ClientSession> session = std::make_unique<ClientSession>(root);
    TF_CHECK_OK(session->Run({x}, &outputs));
    std::cout << outputs[0].matrix<float>();

}
