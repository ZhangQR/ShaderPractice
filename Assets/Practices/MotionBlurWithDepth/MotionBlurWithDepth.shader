Shader "ZhangQr/PostProcess/MotionBlurWithDepth"
{
	Properties 
    {
		_MainTex ("MainTex", 2D) = "white" {}
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        int _BlurAmount;
        float _BlurInterval;
        sampler2D _CameraDepthTexture;
        float4x4 _PreviousVPTranform;
        float4x4 _CurrentInverseVPTranform;


        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
            float depth = Linear01Depth(d);
            
            // 把 (i.uv,depth) 映射回 (-1,1) 的范围，也就是标准设备体积
            float3 NDCposition = float3(i.uv.x * 2 - 1,i.uv.y * 2 - 1,depth * 2 -1);
            
            // 通过 VP 的逆矩阵，变回世界坐标
            float4 currentWorldPosition = mul(_CurrentInverseVPTranform,NDCposition);

            // 别忘了归一化
            currentWorldPosition /= currentWorldPosition.w;
            
            float4 PreviousNDCPosition = mul(_PreviousVPTranform,currentWorldPosition);

            PreviousNDCPosition /= PreviousNDCPosition.w;

            //float2 previoursUV = float2(PreviousNDCPosition.x / 2 + 0.5f,PreviousNDCPosition.y / 2 + 0.5f);

            // 求出速度
            float2 velocity = (NDCposition.xy - PreviousNDCPosition.xy) / 2.0f;

            fixed3 col = fixed3(0,0,0);
            float2 uv = i.uv;
            for(int i = 0 ; i<_BlurAmount ; i++)
            {
                col += tex2D(_MainTex,uv + velocity * _BlurInterval*i);
            }

            col /= _BlurAmount;
            return fixed4(col,1);
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
