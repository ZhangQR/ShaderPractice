Shader "ZhangQr/Virualize/GetDepthAndNormal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            bool _IsGetDepth;

            //camera.depthTextureMode = DepthTextureMode.Depth;
            sampler2D _CameraDepthTexture;

            // camera.depthTextureMode = DepthTextureMode.DepthNormals;
            sampler2D _CameraDepthNormalsTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if(_IsGetDepth)
                {
                    float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                    float linearDepth = Linear01Depth(depth);
                    return fixed4(linearDepth, linearDepth, linearDepth, 1.0);
                }
                else
                {
                    fixed4 rawNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
                    float3 normal = DecodeViewNormalStereo((float4)rawNormal);
                    return fixed4(normal * 0.5 + 0.5, 1.0);
                }
            }
            ENDCG
        }
    }
}
