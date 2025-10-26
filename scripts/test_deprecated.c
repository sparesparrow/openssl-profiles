#include <openssl/evp.h>
#include <openssl/rsa.h>
#include <openssl/engine.h>
#include <stdio.h>

int main() {
    // Test deprecated EVP_MD_CTX_new (should fail compilation with -Werror=deprecated-declarations)
    EVP_MD_CTX *ctx = EVP_MD_CTX_new();
    if (ctx) {
        EVP_MD_CTX_free(ctx);
    }

    // Test deprecated RSA_sign (should fail compilation with -Werror=deprecated-declarations)
    RSA *rsa = RSA_new();
    unsigned char sig[256];
    unsigned int siglen;
    unsigned char data[] = "test";
    unsigned char digest[32] = {0};

    if (rsa) {
        RSA_sign(NID_sha256, digest, 32, sig, &siglen, rsa);
        RSA_free(rsa);
    }

    // Test deprecated ENGINE functions (should fail compilation with -Werror=deprecated-declarations)
    ENGINE *engine = ENGINE_new();
    if (engine) {
        ENGINE_free(engine);
    }

    printf("Deprecated APIs compiled successfully (this should not happen in FIPS mode)\n");
    return 0;
}