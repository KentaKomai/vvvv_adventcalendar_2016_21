//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 

//transforms
float4x4 tW: WORLD;
float4x4 tV: VIEW;
float4x4 tWV: WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tP: PROJECTION;

float4x4 tA <string uiname="Second Transform";>;

//alpha
float Alpha <float uimin=0.0; float uimax=1.0;> = 1;

Texture2D Tex <string uiname="Texture";>;

SamplerState g_samLiner
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};

float4x4 tTex <string uiname="Texture Transform"; bool uvspec=true;>;
float4x4 tColor <string uiname="Color Transform";>;

struct vs2ps
{
	float4 PosWVP: SV_POSITION;
	float4 TexCd: TEXCOORD0;
	float4 NormV: TEXCOORD1;
};

vs2ps VS(
	float4 Pos0: POSITION,
	float4 Norm0: NORMAL,
	float4 TexCd: TEXCOORD0)
{
	vs2ps Out = (vs2ps)0;
	
	Out.NormV = normalize(mul(Norm0, tA));
	
	float4 pos = mul(float4(0,0,0,1), tWV);
	
	Out.PosWVP = mul(pos + mul(Pos0, tA), tP);
	Out.TexCd = mul(TexCd, tTex);
	return Out;
}

float4 colore : COLOR = 1;

float4 PS(vs2ps In): SV_Target
{
	float4 col = Tex.SampleLevel(g_samLiner, In.TexCd.xy, 1);
	col.a *= Alpha;
	
	return col;
}

technique10 constant
{
	pass P0
	{
		SetVertexShader(CompileShader(vs_4_0, VS()));
		SetPixelShader(CompileShader(ps_4_0, PS()));
	}
}