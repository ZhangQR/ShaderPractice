using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class MotionBlurCameraMove : MonoBehaviour
{
    public Transform StartPoint;
    public Transform EndPoint;
    public Transform Center;
    public float MoveSpeed;
    private Vector3 endPosition;
    private void Start()
    {
        Vector3 endPosition = StartPoint.position;
        transform.position = EndPoint.position;
    }
    void Update()
    {
        transform.position = Vector3.Slerp(transform.position - Center.position,
            endPosition - Center.position, Time.deltaTime * MoveSpeed) + Center.position;
        transform.LookAt(Center.position);
        //if((transform.position - endPosition).magnitude <= 0.001f)
        //{
        //    endPosition = endPosition == StartPoint.position ? EndPoint.position : StartPoint.position;
        //}
    }
}
