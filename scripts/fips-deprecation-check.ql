import cpp

from FunctionCall call
where call.getTarget().getName() = "EVP_MD_CTX_new" and
      not call.getFile().getBaseName().matches("test_deprecated%")
select call, "Deprecated EVP_MD_CTX_new usage detected"