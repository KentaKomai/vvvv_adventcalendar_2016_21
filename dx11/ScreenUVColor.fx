//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 

Texture2D texture2d <string uiname="Texture";>;
Texture2D randomVector <string uiname="RandomTexture";>;
float distortion <string uiname="Mesh Distortion Ratio";>;

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
	float4 Pos : TEXCOORD1;
	float4 WPos: TEXCOORD2;
};

vs2ps VS(VS_IN input)
{
    vs2ps output = (vs2ps)0;
	
    output.PosWVP  = mul(input.PosO,mul(tW,tVP));
	output.WPos = input.PosO;
    output.TexCd = input.TexCd;
	output.Pos = output.PosWVP;
	
    return output;
}

[maxvertexcount(6)]
void GSScene( triangleadj vs2ps input[6], inout TriangleStream<vs2ps> OutputStream )
{	
    vs2ps output = (vs2ps)0;

    for( uint i=0; i<3; i++ )
    {
        output.PosWVP = input[i].PosWVP;
        output.TexCd = input[i].TexCd;
    	output.Pos = input[i].Pos;
		
        OutputStream.Append( output );
    }
	
    OutputStream.RestartStrip();
	
    for( i=0; i<3; i++ )
    {
    	//float4 vec = texture2d.Sample(linearSampler, float2(0,0));
    	//float4 vec = randomVector.Sample(linearSampler, float2(0,0));
        float4 newpos = input[i].WPos * float4(2,2,2,1);
    	output.PosWVP = mul(newpos, mul(tW,tVP));
    	//output.PosWVP = mul(output.PosWVP, float4(vec.xyz, 1));
        output.TexCd = input[i].TexCd;
    	output.Pos = input[i].Pos * 2.0f;
        
        OutputStream.Append( output );
    }
    OutputStream.RestartStrip();
}


float4 PS(vs2ps In): SV_Target
{
    //float4 col = float4(0,0,0,1);
	 float2 uv = (In.Pos.xy / In.Pos.w * float2(1, -1) + float2(1, 1)) * 0.5;
    float4 col = float4(uv, 0, 0);
    col = texture2d.Sample(linearSampler,uv) * cAmb;
    return col;
	//float3 screenUV = 0.5f * (In.PosWVP.xyz/In.PosWVP.w) + 0.5f;
	//col = float4(screenUV,1);
	//col = texture2d.Sample(linearSampler, screenUV.xy);
	//col.r = screenUV.x;
	//col.g = screenUV.y;
	//return col;
}

technique10 Constant
{
	pass P0
	{
		SetVertexShader  ( CompileShader( vs_4_0, VS()      ) );
		SetGeometryShader( CompileShader( gs_4_0, GSScene() ) );
		SetPixelShader   ( CompileShader( ps_4_0, PS()      ) );
	}
}




