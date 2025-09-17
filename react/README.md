# Civic Issue Reporting Web Portal

A comprehensive web portal for managing civic issues reported through a Flutter mobile application. This portal provides administrators and department managers with tools to efficiently process, prioritize, and resolve community issues.

## Features

### 🏠 Dashboard
- **Overview Statistics**: Real-time metrics showing total issues, pending, in-progress, resolved, and urgent issues
- **Recent Issues**: Quick view of the latest reported issues with key details
- **Search & Filter**: Find specific issues by title, description, location, or reporter
- **Status Tracking**: Visual indicators for issue status and priority levels

### 📋 Issue Management
- **Advanced Filtering**: Filter by status, priority, department, date range, and assignee
- **Bulk Operations**: Select multiple issues for batch actions (assign, change priority, update status)
- **Sorting Options**: Sort by date, priority, status, title, or department
- **Detailed View**: Comprehensive issue information with location, reporter, and assignment details

### 🏢 Department Assignment
- **Smart Routing**: AI-powered suggestions for department assignment based on issue content
- **Department Overview**: Capacity, current workload, and performance metrics for each department
- **Auto-Assignment**: Bulk assignment of issues to appropriate departments
- **Contact Information**: Direct access to department managers and contact details

### 🎯 Priority Management
- **Smart Prioritization**: AI-driven priority scoring based on multiple factors
- **Priority Rules**: Configurable rules for automatic priority assignment
- **Impact Analysis**: Detailed scoring for impact, urgency, and complexity
- **Bulk Priority Updates**: Mass update of issue priorities
- **Confidence Scoring**: AI confidence levels for priority recommendations

### 📊 Analytics & Insights
- **Performance Metrics**: Department efficiency, resolution times, and satisfaction rates
- **Trend Analysis**: Historical data and trend visualization
- **Category Breakdown**: Issue distribution by category and priority
- **Location Analytics**: Top issue locations and geographic insights
- **Export Capabilities**: Generate PDF and Excel reports

## Technology Stack

- **Frontend**: React 19.1.1 with JSX
- **Styling**: Tailwind CSS 4.1.13
- **Build Tool**: Vite 7.1.2
- **Icons**: Lucide React
- **State Management**: React Hooks (useState, useEffect)

## Project Structure

```
src/
├── components/
│   ├── Dashboard.jsx              # Main dashboard with overview
│   ├── IssueManagement.jsx        # Issue filtering and management
│   ├── DepartmentAssignment.jsx   # Department routing and assignment
│   ├── PriorityManagement.jsx    # Smart prioritization system
│   ├── Analytics.jsx             # Reports and insights
│   └── Navigation.jsx            # Main navigation component
├── App.jsx                       # Main application component
├── App.css                       # Global styles
├── index.css                     # Base styles
└── main.jsx                      # Application entry point
```

## Getting Started

### Prerequisites
- Node.js (version 16 or higher)
- npm or yarn package manager

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd my-project
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   Navigate to `http://localhost:5173` to view the application

### Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## Usage

### Navigation
- Use the sidebar navigation to switch between different sections
- The mobile menu (hamburger icon) provides access to navigation on smaller screens
- The top bar shows the current section and provides search functionality

### Managing Issues
1. **View Issues**: Start at the Dashboard for an overview
2. **Filter & Search**: Use the Issue Management section for detailed filtering
3. **Assign Issues**: Route issues to appropriate departments
4. **Set Priorities**: Use smart prioritization or manual assignment
5. **Track Progress**: Monitor resolution through Analytics

### Department Assignment
1. **Review Unassigned Issues**: See all issues waiting for department assignment
2. **Check Department Capacity**: View current workload and capacity for each department
3. **Assign Issues**: Select issues and assign to appropriate departments
4. **Auto-Assign**: Use AI-powered bulk assignment for efficiency

### Priority Management
1. **Review Smart Priorities**: See AI-recommended priorities with confidence scores
2. **Configure Rules**: Set up custom priority assignment rules
3. **Bulk Updates**: Apply priority changes to multiple issues
4. **Monitor Performance**: Track priority accuracy and effectiveness

## API Integration

The current implementation uses mock data. To integrate with a real backend:

1. **Replace Mock Data**: Update the `useEffect` hooks in each component
2. **Add API Calls**: Implement actual HTTP requests using fetch or axios
3. **Error Handling**: Add proper error handling and loading states
4. **Authentication**: Implement user authentication and authorization

### Example API Integration

```javascript
// Replace mock data with actual API calls
useEffect(() => {
  const fetchIssues = async () => {
    try {
      const response = await fetch('/api/issues');
      const data = await response.json();
      setIssues(data);
    } catch (error) {
      console.error('Error fetching issues:', error);
    }
  };
  
  fetchIssues();
}, []);
```

## Customization

### Styling
- Modify `src/App.css` for global styles
- Update Tailwind classes in components for specific styling
- Customize the color scheme by modifying Tailwind configuration

### Components
- Each component is self-contained and can be modified independently
- Add new features by extending existing components
- Create new components following the established patterns

### Data Structure
- Update the mock data structures to match your backend API
- Modify the filtering and sorting logic as needed
- Add new fields to issue objects for additional functionality

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation for common solutions

## Roadmap

- [ ] Real-time notifications
- [ ] Advanced charting and visualization
- [ ] Mobile-responsive improvements
- [ ] User role management
- [ ] API integration
- [ ] Automated reporting
- [ ] Integration with external systems