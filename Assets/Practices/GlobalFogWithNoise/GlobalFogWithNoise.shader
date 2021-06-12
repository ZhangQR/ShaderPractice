Shader "ZhangQr/PostPorocess/GlobalFogWithNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"
        
        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;
        float4x4 _InterpolatedRays;
        sampler2D _CameraDepthTexture;
        sampler2D _NoiseTexture;
        fixed4 _FogColor;
        float _MinHeight;
        float _MaxHeight;
        float _FogDensity;
        float _SpeedX;
        float _SpeedY;
        float _NoiseStrength;
        
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            float3 interpolatedRay : TEXCOORD1;
            //half2 uv_depth : TEXCOORD2;
        };


        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            //o.uv_depth = v.uv;
            
            //#if UNITY_UV_STARTS_AT_TOP
			//if (_MainTex_TexelSize.y < 0)
			//	o.uv_depth.y = 1 - o.uv_depth.y;
			//#endif
            
            // 只有 4 个顶点，设置好之后到片元着色器会自动插值
            int index = 0;
            if(v.uv.x < 0.5f && v.uv.y < 0.5f)
            {
                index = 2;
            }else if (v.uv.x > 0.5f && v.uv.y > 0.5f)
            {
                index = 1;
            }else if (v.uv.x > 0.5f && v.uv.y < 0.5f)
            {
                index = 3;
            }
            
            //#if UNITY_UV_STARTS_AT_TOP
			//if (_MainTex_TexelSize.y < 0)
			//	index = 3 - index;
			//#endif
            
            o.interpolatedRay = _InterpolatedRays[index].xyz;
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv));
            //depth = Linear01Depth(depth);
            float3 worldPosition = _WorldSpaceCameraPos + i.interpolatedRay.xyz * depth;
            
            float2 speed = _Time.y * (float2(_SpeedX,_SpeedY));
            float noise = (tex2D(_NoiseTexture,i.uv + speed).r - 0.1f) * _NoiseStrength;
            float f = (_MaxHeight - worldPosition.y) / (_MaxHeight - _MinHeight);
            f = saturate(f * _FogDensity * noise);

            fixed3 col = tex2D(_MainTex,i.uv).xyz * (1 - f) + _FogColor.xyz * f;
            //fixed3 col = lerp(tex2D(_MainTex,i.uv).xyz,_FogColor.xyz,f);

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
