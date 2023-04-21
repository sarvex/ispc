// Test ensures performant codegen for accumulations over for loops
// See [GitHub Issue core/#2460](https://github.com/ispc/ispc/issues/2460)

// RUN: %{ispc} -o %t.asm %s --emit-asm --nostdlib --target=avx512skx-x4 --arch=x86-64 -DEXPLICIT_VECTOR4=0
// RUN: FileCheck %s --input-file=%t.asm --check-prefix=CHECK_VECTOR0
// RUN: %{ispc} -o %t.asm %s --emit-asm --nostdlib --target=avx512skx-x4 --arch=x86-64 -DEXPLICIT_VECTOR4=1
// RUN: FileCheck %s --input-file=%t.asm --check-prefix=CHECK_VECTOR1

// CHECK_VECTOR0:	[[LABEL:[a-zA-Z0-9_.]*]]:
// CHECK_VECTOR0:		vmovups xmm0, xmmword ptr [rsi + 4*rcx]
// CHECK_VECTOR0:		vmaxps  xmm0, xmm0, xmmword ptr [rdx + 4*rcx]
// CHECK_VECTOR0:		vmaxps  xmm0, xmm0, xmmword ptr [rdi + 4*rcx]
// CHECK_VECTOR0:		vmovdqu xmmword ptr [rdi + 4*rcx], xmm0
// CHECK_VECTOR0:		add     rcx, 4
// CHECK_VECTOR0:		cmp     rcx, r9
// CHECK_VECTOR0:		jl      [[LABEL]]

// CHECK_VECTOR1:	[[LABEL:[a-zA-Z0-9_.]*]]:
// CHECK_VECTOR1:		vmovaps xmm0, xmmword ptr [rsi + 4*rcx]
// CHECK_VECTOR1:		vmaxps  xmm0, xmm0, xmmword ptr [rdx + 4*rcx]
// CHECK_VECTOR1:		vmaxps  xmm0, xmm0, xmmword ptr [rdi + 4*rcx]
// CHECK_VECTOR1:		vmovaps xmmword ptr [rdi + 4*rcx], xmm0
// CHECK_VECTOR1:		add     rcx, 4
// CHECK_VECTOR1:		cmp     rcx, r9
// CHECK_VECTOR1:		jl      [[LABEL]]

// REQUIRES: X86_ENABLED

struct FVector4f
{
#if EXPLICIT_VECTOR4 == 0
	float V[4];
#else
	float<4> V;
#endif
};
extern varying float max(const varying float, const varying float);

// Extra movsxd, vmovd, vpinsrd after 2x vmaxps with EXPLICIT_VECTOR4 0. Extra cdqe with EXPLICIT_VECTOR4 1.
inline uniform FVector4f VectorMax(const uniform FVector4f& V1, const uniform FVector4f& V2)
{
	varying float S0, S1, Result;
	*((uniform FVector4f *uniform)&S0) = *((uniform FVector4f *uniform)&V1);
	*((uniform FVector4f *uniform)&S1) = *((uniform FVector4f *uniform)&V2);

	Result = max(S0, S1);

	return *((uniform FVector4f *uniform)&Result);
}

export void Max_Uniform_FVector4f(uniform float A[], uniform float B[], uniform float C[], uniform int Num)
{
	for(uniform int i = 0; i < Num; i+=4)
	{
		uniform FVector4f *uniform pA = (uniform FVector4f *uniform)&A[i];
		uniform FVector4f *uniform pB = (uniform FVector4f *uniform)&B[i];
		uniform FVector4f *uniform pC = (uniform FVector4f *uniform)&C[i];

		*pA = VectorMax(VectorMax(*pB, *pC), *pA);
	}
}

inline uniform FVector4f VectorMax1(const uniform FVector4f& V1, const uniform FVector4f& V2)
{
	uniform FVector4f Result;

	foreach(i = 0 ... 4)
	{
		Result.V[i] = max(V1.V[i], V2.V[i]);
	}

	return Result;
}

// Extra cdqe stack and maskmov usage. Should be using xmm throughout.
export void Max1_Uniform_FVector4f(uniform float A[], uniform float B[], uniform float C[], uniform int Num)
{
	for(uniform int i = 0; i < Num; i+=4)
	{
		uniform FVector4f *uniform pA = (uniform FVector4f *uniform)&A[i];
		uniform FVector4f *uniform pB = (uniform FVector4f *uniform)&B[i];
		uniform FVector4f *uniform pC = (uniform FVector4f *uniform)&C[i];

		*pA = VectorMax1(VectorMax1(*pB, *pC), *pA);
	}
}