import React, { useState, useEffect } from 'react';
import { Bar, Pie } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
} from 'chart.js';
import { 
  BarChart3, 
  MapPin,
  RefreshCw,
} from 'lucide-react';

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
);

const Analytics = () => {
  const [issues, setIssues] = useState([]);
  const [analyticsData, setAnalyticsData] = useState(null);
  const [loading, setLoading] = useState(true);

  const mockIssues = [
      {
        id: "mock-1",
        issue: "Pothole on Main Street",
        department: "Public Works",
        priority: "High",
        status: "Resolved",
        date: "2024-01-15T10:30:00Z",
        location: "Downtown",
      },
      {
        id: "mock-2",
        issue: "Broken Street Light",
        department: "Utilities",
        priority: "Medium",
        status: "In Progress",
        date: "2024-01-14T18:45:00Z",
        location: "Oak Avenue",
      },
  ];

  useEffect(() => {
    const fetchIssues = async () => {
        try {
            setLoading(true);
            const response = await fetch('http://localhost:3001/api/issues');
            if(!response.ok) throw new Error('Server not responding');
            const liveIssues = await response.json();
            setIssues([...liveIssues, ...mockIssues]);
        } catch (error) {
            console.error("Failed to fetch issues, falling back to mock data:", error);
            setIssues(mockIssues);
        }
    };
    fetchIssues();
  }, []);

  useEffect(() => {
    if (issues.length > 0) {
      setLoading(true);
      const totalIssues = issues.length;
      const resolvedIssues = issues.filter(i => i.status === 'Resolved').length;
      
      const departmentStats = issues.reduce((acc, issue) => {
          if (!acc[issue.department]) {
              acc[issue.department] = { name: issue.department, totalIssues: 0, resolved: 0 };
          }
          acc[issue.department].totalIssues++;
          if (issue.status === 'Resolved') {
              acc[issue.department].resolved++;
          }
          return acc;
      }, {});

      const categoryBreakdown = issues.reduce((acc, issue) => {
          const category = issue.category || 'Other';
          if(!acc[category]) {
              acc[category] = { category, count: 0 };
          }
          acc[category].count++;
          return acc;
      }, {});

      const priorityDistribution = issues.reduce((acc, issue) => {
          const priority = issue.priority || 'N/A';
          if(!acc[priority]) {
              acc[priority] = { priority, count: 0 };
          }
          acc[priority].count++;
          return acc;
      }, {});

      const topLocations = issues.reduce((acc, issue) => {
          const location = issue.location || 'Unknown';
          if(!acc[location]) {
              acc[location] = { location, count: 0 };
          }
          acc[location].count++;
          return acc;
      }, {});

      setAnalyticsData({
        overview: {
          totalIssues,
          resolvedIssues,
          pendingIssues: totalIssues - resolvedIssues,
          satisfactionRate: 87.3, // Mocked for now
        },
        departmentStats: Object.values(departmentStats),
        categoryBreakdown: Object.values(categoryBreakdown).map(c => ({...c, percentage: ((c.count / totalIssues) * 100).toFixed(1) })),
        priorityDistribution: Object.values(priorityDistribution).map(p => ({...p, percentage: ((p.count / totalIssues) * 100).toFixed(1) })),
        topLocations: Object.values(topLocations).sort((a,b) => b.count - a.count).slice(0, 5)
      });
      setLoading(false);
    }
  }, [issues]);

  const handleRefresh = () => {
    setLoading(true);
    setTimeout(() => setLoading(false), 500);
  };
  
  const barChartData = {
    labels: analyticsData?.departmentStats.map(d => d.name),
    datasets: [
      {
        label: 'Total Issues',
        data: analyticsData?.departmentStats.map(d => d.totalIssues),
        backgroundColor: 'rgba(54, 162, 235, 0.6)',
      },
      {
        label: 'Resolved Issues',
        data: analyticsData?.departmentStats.map(d => d.resolved),
        backgroundColor: 'rgba(75, 192, 192, 0.6)',
      },
    ],
  };

  const pieChartData = {
      labels: analyticsData?.priorityDistribution.map(p => p.priority),
      datasets: [{
          data: analyticsData?.priorityDistribution.map(p => p.count),
          backgroundColor: [
              '#FF6384', // High
              '#FFCD56', // Medium
              '#4BC0C0', // Low
              '#C9CBCF'  // Urgent/Other
          ],
      }]
  };


  if (loading || !analyticsData) {
    return <div className="p-6 text-center">Loading analytics...</div>;
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">Analytics & Insights</h1>
        <div className="flex items-center space-x-4">
          <button
            onClick={handleRefresh}
            disabled={loading}
            className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">Total Issues</p>
            <p className="text-2xl font-bold text-gray-900">{analyticsData.overview.totalIssues}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">Resolution Rate</p>
            <p className="text-2xl font-bold text-green-600">
                {Math.round((analyticsData.overview.resolvedIssues / analyticsData.overview.totalIssues) * 100) || 0}%
            </p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">Pending</p>
            <p className="text-2xl font-bold text-yellow-600">{analyticsData.overview.pendingIssues}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">Satisfaction Rate</p>
            <p className="text-2xl font-bold text-purple-600">{analyticsData.overview.satisfactionRate}%</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        <div className="lg:col-span-3 bg-white rounded-lg shadow-md border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Department Performance</h2>
            <div className="h-80">
                <Bar data={barChartData} options={{ maintainAspectRatio: false }} />
            </div>
        </div>
        <div className="lg:col-span-2 bg-white rounded-lg shadow-md border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Priority Distribution</h2>
            <div className="h-80">
                <Pie data={pieChartData} options={{ maintainAspectRatio: false }} />
            </div>
        </div>
      </div>


       <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
         <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Issue Categories</h2>
          </div>
          <div className="p-6 space-y-3">
              {analyticsData.categoryBreakdown.map((category, index) => (
                <div key={index} className="flex items-center justify-between">
                  <span className="text-sm font-medium text-gray-900">{category.category}</span>
                  <span className="text-sm text-gray-600">{category.count} ({category.percentage}%)</span>
                </div>
              ))}
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Top Locations</h2>
          </div>
          <div className="p-6 space-y-3">
            {analyticsData.topLocations.map((location, index) => (
              <div key={index} className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <MapPin className="w-4 h-4 text-gray-400" />
                  <span className="text-sm font-medium text-gray-900">{location.location}</span>
                </div>
                <span className="text-sm text-gray-600">{location.count}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Analytics;