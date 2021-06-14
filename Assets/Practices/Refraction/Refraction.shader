Shader "ZhangQr/Refraction"
{
    Properties
    {
        _MainCube("MainCube",Cube) = "_Skybox"{}
        _RefractionRatio("RefractionRatio",Range(0,5)) = 0
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 worldPosition : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            samplerCUBE _MainCube;
            float _RefractionRatio;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 cameraModlePosition = mul(unity_WorldToObject,_WorldSpaceCameraPos);
                float3 worldSpaceViewDir = UnityWorldSpaceViewDir(i.worldPosition);
                float3 refractionDir = refract(normalize(worldSpaceViewDir),normalize(i.worldNormal),1/_RefractionRatio);
                fixed4 col = texCUBE(_MainCube,refractionDir);
                return col;
            }
            ENDCG
        }
    }
}
