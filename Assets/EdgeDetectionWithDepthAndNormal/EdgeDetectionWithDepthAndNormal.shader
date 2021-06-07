Shader "ZhangQr/PostProcess/EdgeDetectionWithDepthAndNormal"
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            float _SampleDistance;
            half4 _Sensitivity;
            sampler2D _CameraDepthNormalsTexture;

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


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_CameraDepthNormalsTexture, i.uv);
                float3 normal = DecodeViewNormalStereo(col) * 0.5f + 0.5f;
                //return fixed4(normal.xyz,1);
                return fixed4(col.xy,normal.z,1);
            }
            ENDCG
        }
    }
}
