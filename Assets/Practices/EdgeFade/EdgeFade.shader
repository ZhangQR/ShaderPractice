Shader "Unlit/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FadeMul ("FadeMul", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "DisableBatching"="True" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FadeMul;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 objectClipPos = UnityObjectToClipPos(float4(0,0,0,1));
                
                // -1 to 1 range edge to edge
                float2 objScreenPos = objectClipPos.xy / objectClipPos.w;
                
                // 0 to 1 range with 0 at edge, 1 at center
                float2 normDistToEdge = 1 - abs(objScreenPos);
 
                // get min distance, mul > 1 to make fade happen closer to edge
                float fade = saturate(min(normDistToEdge.x, normDistToEdge.y) * _FadeMul);
                
                o.color = fixed4(0,0,0,1);

                // multiply out color by fade, or however else you want to pass the info to the fragment
                o.color.a *= fade;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
