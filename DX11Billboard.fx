

float4x4 tWV: WORLDVIEW;
float4x4 tP: PROJECTION;

float4x4 tA <string uiname="Transform";>;
float4 tC <bool color=true;string uiname="Color";>;
float Alpha <float uimin=0.0; float uimax=1.0;> = 1;
Texture2D Tex <string uiname="Texture";>;

SamplerState g_samLiner
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};

struct VSIN
{
	float4 Pos: POSITION;
	float4 Normal: NORMAL;
	float4 TexCd: TEXCOORD0;
};

struct vs2ps
{
	float4 PosWVP: SV_POSITION;
	float4 TexCd: TEXCOORD0;
	float4 NormV: TEXCOORD1;
};

vs2ps VS(VSIN In)
{
	// ignore scale and rotate and any more.
	float4 pos = mul(float4(0,0,0,1), tWV);
	
	vs2ps Out;
	Out.NormV  = In.Normal;
	Out.PosWVP = mul(pos + mul(In.Pos, tA), tP);
	Out.TexCd  = In.TexCd;
	
	return Out;
}

float4 PS(vs2ps In): SV_Target
{
	float4 col = Tex.SampleLevel(g_samLiner, In.TexCd.xy, 1) * tC;
	//col = col + tC;
	//float4 col = tC;
	col.a *= Alpha;
	
	if(col.a == 0) discard;
	
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