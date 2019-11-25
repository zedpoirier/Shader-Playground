Shader "ImageEffects/DepthColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_NearColor ("Near Clip Color", Color) = (0.5, 0.3, 0.8, 1)
		_FarColor ("Far Clip Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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

			sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _NearColor;
			fixed4 _FarColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // convert to depth
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				depth = pow(Linear01Depth(depth), 0.8);
                return lerp(_NearColor, _FarColor, depth);
            }
            ENDCG
        }
    }
}
